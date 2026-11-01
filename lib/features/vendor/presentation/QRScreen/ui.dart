import 'package:flutter/material.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';
import 'package:easy2eat/features/vendor/providers/qrcode-generation/qr-generator.dart';
import 'package:easy2eat/features/vendor/providers/Notifiers/qr-provider.dart';

class OrderQrDialogWidget extends StatelessWidget {
  final OrderModel? order;

  const OrderQrDialogWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_2, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              "No order selected for QR",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rider Pickup QR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Order ID and Customer Name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                order!.orderID,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(' • ', style: TextStyle(color: Colors.grey)),
              Text(
                order!.customerName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Render QR Code Widget using OrderQRGenerator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: OrderQRGenerator.buildQrImageWidget(order!, size: 200.0),
          ),
          const SizedBox(height: 12),

          // Subtitle / Instruction text
          const Text(
            'Show this QR code to the delivery rider\nfor pickup verification',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),

          // Close / Done Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}