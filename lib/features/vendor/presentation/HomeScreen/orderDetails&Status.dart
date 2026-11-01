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
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchVendorOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Manually trigger a refresh to fetch updated Firestore orders
  void _refreshOrders() {
    setState(() {
      _ordersFuture = _fetchVendorOrders();
    });
  }

  /// 1. Fetch active orders from Firestore (seeds mock data if collection is empty)
  Future<List<OrderModel>> _fetchVendorOrders() async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('orders');
      final snapshot = await collectionRef.get();

      if (snapshot.docs.isEmpty) {
        debugPrint("Firestore 'orders' is empty. Seeding initial mock orders...");
        await _seedInitialMockOrders(collectionRef);
        final freshSnapshot = await collectionRef.get();
        return freshSnapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .where((order) => order.status != 'delivered' && !order.isDelivered)
            .toList();
      }

      return snapshot.docs
          .map((doc) => OrderModel.fromJson(doc.data()))
          .where((order) => order.status != 'delivered' && !order.isDelivered)
          .toList();
    } catch (e) {
      debugPrint("Failed to fetch vendor orders: $e");
      return [];
    }
  }

  /// 2. Seed mock orders so the UI isn't empty on first launch
  Future<void> _seedInitialMockOrders(CollectionReference collectionRef) async {
    final List<OrderModel> mockOrders = [
      OrderModel(
        orderID: 'ORD-9824',
        customerID: 'CUST-001',
        customerName: 'Alex',
        customerPhone: '+60123456789',
        orderItems: '2x Big Mac, 1x French Fries',
        itemsSubtotal: 35.00,
        deliveryFee: 5.00,
        taxAmount: 2.40,
        isPaid: true,
        paymentMethod: 'Credit Card',
        status: 'pending',
        timeAgo: '2 mins ago',
        location: 'APU Campus Cafeteria, Bukit Jalil',
        deliveryAddress: 'Residensi Park, Bukit Jalil, KL',
        notes: 'Less ice on drinks, please.',
      ),
      OrderModel(
        orderID: 'ORD-9825',
        customerID: 'CUST-002',
        customerName: 'Sarah Lim',
        customerPhone: '+60198765432',
        orderItems: '1x Chicken Rice, 1x Teh Tarik',
        itemsSubtotal: 18.00,
        deliveryFee: 4.00,
        taxAmount: 1.32,
        isPaid: true,
        paymentMethod: 'Online Banking',
        status: 'pending',
        timeAgo: '5 mins ago',
        location: 'APU Campus Cafeteria, Bukit Jalil',
        deliveryAddress: 'Enterprise Park, Bukit Jalil, KL',
        notes: 'Extra chili sauce on the side.',
      ),
    ];

    for (var order in mockOrders) {
      final qrPayload = OrderQRGenerator.generatePayload(order);
      final qrBase64 = await OrderQRGenerator.generateQrBase64(order);

      final Map<String, dynamic> dataToStore = {
        ...order.toJson(),
        'qrPayload': qrPayload,
        'qrBase64': qrBase64 ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await collectionRef.doc(order.orderID).set(dataToStore, SetOptions(merge: true));
    }
  }

  /// 3. Advance order status & automatically sync QR data to Firestore on 'Accept & Prepare'
  Future<void> _advanceOrderStatus(OrderModel order, String newStatus) async {
    try {
      final updatedOrder = order.copyWith(status: newStatus);

      final qrPayload = OrderQRGenerator.generatePayload(updatedOrder);
      final qrBase64 = await OrderQRGenerator.generateQrBase64(updatedOrder);

      final Map<String, dynamic> dataToStore = {
        ...updatedOrder.toJson(),
        'qrPayload': qrPayload,
        'qrBase64': qrBase64 ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(updatedOrder.orderID)
          .set(dataToStore, SetOptions(merge: true));

      debugPrint("Order ${updatedOrder.orderID} status updated & QR synced to cloud.");
      _refreshOrders();
    } catch (e) {
      debugPrint("Failed to update order status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderModel>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final orders = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _refreshOrders,
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
              Container(
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
          ],
        );
      },
    );
  }

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