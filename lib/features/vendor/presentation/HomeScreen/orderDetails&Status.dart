import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';
import 'package:easy2eat/features/vendor/providers/qrcode-generation/qr-generator.dart';
import 'package:easy2eat/features/vendor/presentation/QRScreen/ui.dart';

class OrderDetailWidget extends StatefulWidget {
  const OrderDetailWidget({super.key});

  @override
  State<OrderDetailWidget> createState() => _OrderDetailWidgetState();
}

class _OrderDetailWidgetState extends State<OrderDetailWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Manually triggers a refresh UI state (e.g., re-fetching or syncing UI)
  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    // Simulate a brief network/sync pause for smooth UX feedback
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Orders refreshed successfully!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  /// Advance order status & automatically sync QR data to Firestore
  Future<void> _advanceOrderStatus(OrderModel order, String newPreparationStatus) async {
    try {
      String updatedStatus = order.status;
      if (newPreparationStatus == 'done') {
        updatedStatus = 'readyForPickup';
      } else if (newPreparationStatus == 'preparing') {
        updatedStatus = 'preparing';
      }

      final updatedOrder = order.copyWith(
        preparationStatus: newPreparationStatus,
        status: updatedStatus,
      );

      final qrPayload = OrderQRGenerator.generatePayload(updatedOrder);
      final qrBase64 = await OrderQRGenerator.generateQrBase64(updatedOrder);

      final Map<String, dynamic> dataToStore = {
        ...updatedOrder.toJson(),
        'stage': updatedStatus,
        'qrPayload': qrPayload,
        'qrBase64': qrBase64 ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(updatedOrder.orderID)
          .set(dataToStore, SetOptions(merge: true));

      debugPrint("Order ${updatedOrder.orderID} preparationStatus updated to '$newPreparationStatus' & synced.");
    } catch (e) {
      debugPrint("Failed to update order preparation status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder for real-time synchronization with Firestore
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !_isRefreshing) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        final orders = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['orderID'] ??= doc.id;
          return OrderModel.fromJson(data);
        }).where((order) => order.preparationStatus != 'done' && !order.isDelivered).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // Title Header with Manual Refresh Button
            // --------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Live Order Stream & Status Pipeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: _isRefreshing ? null : _handleRefresh,
                  icon: AnimatedRotation(
                    turns: _isRefreshing ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: const Icon(Icons.refresh_rounded, size: 20, color: Colors.black87),
                  ),
                  tooltip: 'Refresh Orders',
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (orders.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Text('All caught up! No active orders', style: TextStyle(color: Colors.grey)),
              )
            else
            // Added RefreshIndicator for pull-to-refresh functionality
              RefreshIndicator(
                onRefresh: _handleRefresh,
                child: Container(
                  height: 450,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return _buildInteractiveOrderCard(context, order);
                      },
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInteractiveOrderCard(BuildContext context, OrderModel order) {
    Color statusColor;
    String nextStatusText;
    String nextStatusValue;

    switch (order.preparationStatus) {
      case 'pending':
      case 'received':
        statusColor = Colors.orange;
        nextStatusText = 'Accept & Prepare -->';
        nextStatusValue = 'preparing';
        break;

      case 'preparing':
        statusColor = Colors.blue;
        nextStatusText = 'Next Almost Done -->';
        nextStatusValue = 'almost done';
        break;

      case 'almost done':
        statusColor = Colors.purpleAccent;
        nextStatusText = 'Complete Order';
        nextStatusValue = 'done';
        break;

      case 'done':
      default:
        statusColor = Colors.green;
        nextStatusText = 'Archived';
        nextStatusValue = 'done';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14, right: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        order.orderID,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: OrderQrDialogWidget(order: order),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_2, size: 15, color: Colors.black87),
                            SizedBox(width: 3),
                            Text(
                              'QR',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.preparationStatus.toUpperCase().replaceAll(',', ' '),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            order.customerName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          const Divider(height: 1, color: Colors.grey),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time, size: 12, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    order.timeAgo,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              if (order.preparationStatus != 'done')
                InkWell(
                  onTap: () {
                    _advanceOrderStatus(order, nextStatusValue);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      nextStatusText,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                const Text(
                  'Completed',
                  style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
