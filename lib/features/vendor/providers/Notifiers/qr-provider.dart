import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';
import 'package:easy2eat/features/vendor/providers/qrcode-generation/qr-generator.dart';

class OrderSyncService {
  /// Transmit and save the complete order details, QR payload, and Base64 data to Cloud Firestore.
  /// This ensures Vendors, Customers, and Riders share a synchronized source of truth using native Firestore calls.
  static Future<bool> saveOrderQrToDatabase(OrderModel order) async {
    try {
      // 1. Generate QR Payload and Base64 string
      final qrPayload = OrderQRGenerator.generatePayload(order);
      final qrBase64 = await OrderQRGenerator.generateQrImageBytes(order);

      // Convert bytes to base64 string if not null
      String qrBase64Str = '';
      if (qrBase64 != null) {
        qrBase64Str = Uri.dataFromBytes(qrBase64, mimeType: 'image/png').toString();
        // Alternatively, if your generator already outputs base64 string, use that.
      }

      // 2. Assemble the data map by merging order.toJson() with QR specific metadata
      // This automatically includes all fields: customerID, notes, deliveryAddress, financials, teammate compatibility fields, etc.
      final Map<String, dynamic> dataToStore = {
        ...order.toJson(),
        'qrPayload': qrPayload,
        'qrBase64': qrBase64Str,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      debugPrint("Transmitting and saving order QR to Cloud Firestore for Order: ${order.orderID}");

      // 3. Save/Merge directly into Firestore 'orders' collection using native SDK
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderID)
          .set(dataToStore, SetOptions(merge: true));

      debugPrint("Order QR and details successfully stored in Cloud Firestore.");
      return true;
    } catch (e) {
      debugPrint("Failed to save order QR to Cloud Firestore: $e");
      return false;
    }
  }
}