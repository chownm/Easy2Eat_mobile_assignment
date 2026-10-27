import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';
import 'package:easy2eat/features/vendor/providers/qrcode-generation/qr-generator.dart';
import 'package:flutter_riverpod/legacy.dart';

/// 1. Currently selected order Provider for QR generation
final selectedOrderForQrProvider = StateProvider<OrderModel?>((ref) => null);

/// 2. Payload provider for currently selected order
final currentQrPayLoadProvider = Provider<String?>((ref) {
  final order = ref.watch(selectedOrderForQrProvider);
  if (order == null) return null;
  return OrderQRGenerator.generatePayload(order);
});

/// 3. QR storage & transmission status
enum QrStorageStatus { idle, loading, success, error }

class QrStorageState {
  final QrStorageStatus status;
  final String? message;
  final String? savedQrData;

  const QrStorageState({
    this.status = QrStorageStatus.idle,
    this.message,
    this.savedQrData,
  });
}

/// 4. Notifier handling QR and order data transmission and storage to Cloud Firestore
class QrStorageNotifier extends Notifier<QrStorageState> {
  @override
  QrStorageState build() {
    return const QrStorageState();
  }

  /// Transmit and save order and QR code data to Cloud Firestore
  Future<bool> saveOrderQrToDatabase(OrderModel order) async {
    state = const QrStorageState(status: QrStorageStatus.loading);

    try {
      // 1. Generate QR Payload and Base64 string
      final qrPayload = OrderQRGenerator.generatePayload(order);
      final qrBase64 = await OrderQRGenerator.generateQrBase64(order);

      // 2. Assemble the complete payload map
      final Map<String, dynamic> dataToStore = {
        'orderID': order.orderID,
        'qrID': order.qrID,
        'customerName': order.customerName,
        'orderItems': order.orderItems,
        'status': order.status,
        'location': order.location,
        'qrPayload': qrPayload,
        'qrBase64': qrBase64 ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      debugPrint("Transmitting and saving order QR to Cloud Firestore: $dataToStore");

      // Save directly into Firestore 'orders' collection
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderID)
          .set(dataToStore, SetOptions(merge: true));

      state = QrStorageState(
        status: QrStorageStatus.success,
        message: 'Order QR successfully stored in Cloud Firestore',
        savedQrData: qrPayload,
      );
      return true;
    } catch (e) {
      debugPrint("Failed to save order QR to Cloud Firestore: $e");
      state = QrStorageState(
        status: QrStorageStatus.error,
        message: e.toString(),
      );
      return false;
    }
  }
}

final qrStorageProvider =
    NotifierProvider<QrStorageNotifier, QrStorageState>(() {
  return QrStorageNotifier();
});
