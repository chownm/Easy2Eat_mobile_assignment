import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';
import 'package:easy2eat/features/vendor/providers/Notifiers/order-provider.dart';
import 'package:easy2eat/features/vendor/presentation/QRScreen/ui.dart';
import 'package:easy2eat/features/vendor/providers/Notifiers/qr-provider.dart';

class OrderDetailWidget extends ConsumerStatefulWidget {
  const OrderDetailWidget({super.key});

  @override
  ConsumerState<OrderDetailWidget> createState() => _OrderDetailWidgetState();
}

class _OrderDetailWidgetState extends ConsumerState<OrderDetailWidget> {
  // Controller to manage the scrollbar and list view scrolling
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Order Stream & Status Pipeline',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
        // Framed Container with a Scrollbar for bounded order management
          Container(
            height: 450, // Fixed height frame to limit space and enable scrolling
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true, // Always show scrollbar indicator for better UX
              child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: false,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _buildInteractiveOrderCard(context, order);
                },
              ),
            ),
          ),
      ],
    );
  }

  // Widget Setting for Order Status Card
  Widget _buildInteractiveOrderCard(BuildContext context, OrderModel order) {
    Color statusColor;
    String nextStatusText;
    String nextStatusValue;

    switch (order.status) {
      case 'pending':
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
      margin: const EdgeInsets.only(bottom: 14, right: 8), // Right margin to give space for scrollbar
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
              Row(
                children: [
                  Text(
                    order.orderID,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Click to generate and show QR code dialog
                  InkWell(
                    onTap: () {
                      ref.read(selectedOrderForQrProvider.notifier).state = order;
                      showDialog(
                        context: context,
                        builder: (context) => const Dialog(
                          backgroundColor: Colors.transparent,
                          child: OrderQrDialogWidget(),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.toUpperCase().replaceAll(',', ' '),
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
              if (order.status != 'done')
                InkWell(
                  onTap: () {
                    _advanceOrderStatus(order.orderID, nextStatusValue);
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

  // Method: Advance order status using copyWith to preserve all fields
  void _advanceOrderStatus(String targetOrderID, String newStatus) {
    final currentOrders = ref.read(orderListProvider);

    final updatedOrders = currentOrders.map((order) {
      if (order.orderID == targetOrderID) {
        return order.copyWith(status: newStatus);
      }
      return order;
    }).toList();

    ref.read(orderListProvider.notifier).updateOrders(updatedOrders);
  }
}