import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy2eat/features/vendor/providers/Notifiers/qr-provider.dart';
import 'package:easy2eat/features/vendor/providers/qrcode-generation/qr-generator.dart';

class OrderQrDialogWidget extends ConsumerWidget {
  const OrderQrDialogWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(selectedOrderForQrProvider);

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
                order.orderID,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(' • ', style: TextStyle(color: Colors.grey)),
              Text(
                order.customerName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Render QR Code Widget
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: OrderQRGenerator.buildQrImageWidget(order, size: 200.0),
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
          const SizedBox(height: 16),

          // Sync to Database Action Button
          Consumer(
            builder: (context, ref, child) {
              final storageState = ref.watch(qrStorageProvider);
              final isLoading =
                  storageState.status == QrStorageStatus.loading;
              final isSuccess =
                  storageState.status == QrStorageStatus.success;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final success = await ref
                              .read(qrStorageProvider.notifier)
                              .saveOrderQrToDatabase(order);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Order QR synced to database!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isSuccess
                              ? Icons.check_circle
                              : Icons.cloud_upload_outlined,
                          size: 18,
                        ),
                  label: Text(
                    isLoading
                        ? 'Saving...'
                        : (isSuccess
                            ? 'Saved to Database'
                            : 'Sync to Database'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSuccess ? Colors.green : Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
