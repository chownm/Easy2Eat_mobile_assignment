import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';

class OrderQRGenerator {
  /// 1. Generate clean QR code payload.
  /// It only encodes the order ID (or qrID) to act as a secure key for database lookup.
  static String generatePayload(OrderModel order) {
    // Uses qrID if available and non-empty, otherwise falls back to orderID
    return (order.qrID.isNotEmpty) ? order.qrID : order.orderID;
  }

  /// 2. Quickly build and render QR image widget on screen
  static Widget buildQrImageWidget(
      OrderModel order, {
        double size = 200.0,
      }) {
    return QrImageView(
      data: generatePayload(order),
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  /// 3. Generate QR code PNG image bytes (useful for uploading to Firebase Storage or sharing)
  static Future<Uint8List?> generateQrImageBytes(
      OrderModel order, {
        double size = 300.0,
      }) async {
    try {
      final painter = QrPainter(
        data: generatePayload(order),
        version: QrVersions.auto,
        gapless: true,
      );

      final ui.Image image = await painter.toImage(size);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("Error generating QR code image bytes: $e");
      return null;
    }
  }

  /// 4. Generate Base64 QR code string (for storing directly in database string fields)
  static Future<String?> generateQrBase64(
      OrderModel order, {
        double size = 300.0,
      }) async {
    final bytes = await generateQrImageBytes(order, size: size);
    if (bytes == null) return null;
    return base64Encode(bytes);
  }
}