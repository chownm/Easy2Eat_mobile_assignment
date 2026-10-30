import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/active_delivery.dart';
import '../../../../core/theme/theme.dart';

class QrCodeScan extends StatefulWidget {
  const QrCodeScan({super.key});

  @override
  State<QrCodeScan> createState() => _QrCodeScanState();
}

class _QrCodeScanState extends State<QrCodeScan> {
  final MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double scanWindowSize = 200.0;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    // Define the small 200x200 scan window rectangle
    final Rect scanWindowRect = Rect.fromCenter(
      center: Offset(screenWidth / 2, (screenHeight / 2) - 50),
      width: scanWindowSize,
      height: scanWindowSize,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: ThemesColors.brandOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemesColors.darkCharcoal),
          onPressed: () {
            Navigator.maybePop(context);
          },
          iconSize: 28,
        ),
        title: const Text(
          'Scan QR Code',
          style: TextStyle(
            color: ThemesColors.darkCharcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                final isTorchOn = state.torchState == TorchState.on;
                return Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: isTorchOn ? Colors.yellow : Colors.grey[300],
                );
              },
            ),
            iconSize: 28.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Live Camera Preview with Restricted Scan Window
          MobileScanner(
            controller: cameraController,
            scanWindow: scanWindowRect,
            onDetect: (capture) async {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? scannedCode = barcode.rawValue?.trim();
                if (scannedCode != null && scannedCode.isNotEmpty) {
                  cameraController.stop();

                  try {
                    // 1. Try finding order in Firestore by scanned code or active delivery fallback
                    var doc = await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(scannedCode)
                        .get();

                    if (!doc.exists) {
                      doc = await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(ActiveDeliveryState.currentDeliveryNumber)
                          .get();
                    }

                    if (doc.exists && doc.data() != null) {
                      final String matchedId = doc.id;

                      // Update the matched order in Firestore
                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(matchedId)
                          .set({
                        'qrScanned': true,
                        'status': 'vendor_qr_scanned',
                      }, SetOptions(merge: true));

                      // Automatically set matched order as current active delivery
                      ActiveDeliveryState.currentDeliveryNumber = matchedId;
                      ActiveDeliveryState.markVendorQrScanned();

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'QR Code verified for $matchedId!',
                            ),
                            backgroundColor: ThemesColors.success,
                          ),
                        );
                        Navigator.pop(context, matchedId);
                      }
                      break;
                    } else {
                      // Show error if scanned QR code doesn't match any accepted order
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Invalid QR Code! Does not match any accepted order.',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        cameraController.start(); // Resume scanning
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Verification error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      cameraController.start(); // Resume scanning
                    }
                  }
                }
              }
            },
          ),

          // Custom Dark Mask with Square Cutout Window
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.65),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: scanWindowSize,
                    height: scanWindowSize,
                    margin: const EdgeInsets.only(bottom: 100),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Orange Border Framing the Small Scan Window
          Align(
            alignment: Alignment.center,
            child: Container(
              width: scanWindowSize,
              height: scanWindowSize,
              margin: const EdgeInsets.only(bottom: 100),
              decoration: BoxDecoration(
                border: Border.all(color: ThemesColors.brandOrange, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Instruction Text Below the Small Window
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(top: 180),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Place Vendor QR code inside box to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
