import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/active_delivery.dart';
import '../../../../core/constants/user_session.dart';
import '../../../../core/routing/RiderRouting.dart';
import '../../../../core/theme/theme.dart';
import 'models/delivery_order_model.dart';

class OrderDetail extends StatefulWidget {
  final List<DeliveryOrderData>? orders;

  const OrderDetail({
    super.key,
    this.orders,
  });

  @override
  State<OrderDetail> createState() => OrderDetailState();
}

class OrderDetailState extends State<OrderDetail> {
  static final Set<String> _globalAcceptedOrders = {};
  static final Set<String> _globalDeclinedOrders = {};
  final Set<String> _loadingOrderIds = {};

  late Future<List<DeliveryOrderData>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchOrders();
  }

  void resetOrders() {
    setState(() {
      _globalAcceptedOrders.clear();
      _globalDeclinedOrders.clear();
      _loadingOrderIds.clear();
      _ordersFuture = _fetchOrders();
    });
  }

  Future<List<DeliveryOrderData>> _fetchOrders() async {
    if (widget.orders != null && widget.orders!.isNotEmpty) {
      return widget.orders!;
    }

    try {
      final snapshot = await FirebaseFirestore.instance.collection('orders').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => DeliveryOrderData.fromMap(doc.data(), doc.id))
            .where((order) => order.status != 'delivered' && !order.isDelivered)
            .toList();
      }
    } catch (_) {}

    // Fallback default test orders
    return [
      DeliveryOrderData(
        deliveryId: "Delivery #0001",
        orderTime: "12:45 PM, 26 Oct",
        pickupLocation: "Pickup: Kuala Lumpur",
        dropOffLocation: "Drop Off: Jalan Tun",
        earningAmount: "RM100",
        status: 'pending',
        isDelivered: false,
        foodItems: const [
          FoodItemData(quantity: 1, name: "Pizza", price: "\$10.00"),
          FoodItemData(quantity: 2, name: "Burger", price: "\$15.00"),
          FoodItemData(quantity: 1, name: "Spaghetti", price: "\$12.00"),
          FoodItemData(quantity: 2, name: "French Fries", price: "\$5.00"),
          FoodItemData(quantity: 1, name: "Coca-Cola", price: "\$2.50"),
        ],
      ),
    ];
  }

  /// Default mock food items for list preview
  List<FoodItemData> get _defaultFoodItems => const [
        FoodItemData(quantity: 1, name: "Pizza", price: "\$10.00"),
        FoodItemData(quantity: 2, name: "Burger", price: "\$15.00"),
        FoodItemData(quantity: 1, name: "Spaghetti", price: "\$12.00"),
        FoodItemData(quantity: 2, name: "French Fries", price: "\$5.00"),
        FoodItemData(quantity: 1, name: "Coca-Cola", price: "\$2.50"),
      ];

  /// Individual food item row
  Widget foodDetailRow(int quantity, String foodName, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "${quantity}x",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemesColors.darkCharcoal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              foodName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ThemesColors.darkCharcoal,
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemesColors.darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAccept(String deliveryId) async {
    setState(() {
      _loadingOrderIds.add(deliveryId);
    });

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(deliveryId)
          .set({'isAccepted': true, 'status': 'accepted'}, SetOptions(merge: true));
    } catch (_) {}

    ActiveDeliveryState.currentDeliveryNumber = deliveryId;

    if (mounted) {
      setState(() {
        _loadingOrderIds.remove(deliveryId);
        _globalAcceptedOrders.add(deliveryId);
      });
    }
  }

  Future<void> _handleDecline(String deliveryId) async {
    setState(() {
      _loadingOrderIds.add(deliveryId);
    });

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(deliveryId)
          .set({'isDeclined': true, 'status': 'declined'}, SetOptions(merge: true));
    } catch (_) {}

    if (mounted) {
      setState(() {
        _loadingOrderIds.remove(deliveryId);
        _globalDeclinedOrders.add(deliveryId);
      });
    }
  }

  void _showArrivedConfirmationDialog(
      BuildContext context, String deliveryId, DeliveryOrderData order) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("Confirm Arrival"),
          content: Text("Have you arrived at the delivery location for $deliveryId?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ThemesColors.success),
              onPressed: () async {
                Navigator.pop(ctx);
                await _completeDeliveryAndNotify(deliveryId, order);
              },
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeDeliveryAndNotify(
      String deliveryId, DeliveryOrderData order) async {
    setState(() {
      _loadingOrderIds.add(deliveryId);
    });

    try {
      final uid = UserSession.currentUid ?? 'guest_rider';
      final now = TimeOfDay.now();
      final formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // 1. Update order status to delivered in Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(deliveryId)
          .set({
        'status': 'delivered',
        'isDelivered': true,
      }, SetOptions(merge: true));

      // 2. Send "Food is Delivered" message to customer chat subcollection in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chats')
          .doc("Customer $deliveryId")
          .collection('messages')
          .add({
        'message': 'Food is Delivered',
        'isSender': true,
        'time': formattedTime,
        'status': 'Sent',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 3. Save to Rider Recent Trips in Firestore for Dashboard
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recent_trips')
          .add({
        'deliveryId': deliveryId,
        'earning': order.earningAmount,
        'destination': order.dropOffLocation,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _globalDeclinedOrders.add(deliveryId);
          order.isDeclined = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery completed! "Food is Delivered" sent to customer.'),
            backgroundColor: ThemesColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing delivery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingOrderIds.remove(deliveryId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DeliveryOrderData>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: ThemesColors.brandOrange,
            ),
          );
        }

        final orders = snapshot.data ?? [];
        final activeOrders = orders
            .where((order) =>
                !_globalDeclinedOrders.contains(order.deliveryId) &&
                !order.isDeclined &&
                order.status != 'delivered' &&
                !order.isDelivered)
            .toList();

        // Show empty state when all orders are declined/removed
        if (activeOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  "No incoming orders",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: resetOrders,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh Orders"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemesColors.darkCharcoal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scrollbar(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: activeOrders.length,
            itemBuilder: (context, index) {
              final order = activeOrders[index];
              final String deliveryId = order.deliveryId;
              final bool isAccepted =
                  _globalAcceptedOrders.contains(deliveryId) || order.isAccepted;
              final bool isLoading = _loadingOrderIds.contains(deliveryId);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Delivery ID & Order Time Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              deliveryId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ThemesColors.darkCharcoal,
                              ),
                            ),
                            if (isAccepted) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: ThemesColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "ACCEPTED",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: ThemesColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        // Order Incoming Time & Date Display
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 18,
                              color: ThemesColors.darkCharcoal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              order.orderTime,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ThemesColors.darkCharcoal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Inner Card with FIXED height & dynamic food details list
                    Container(
                      width: double.infinity,
                      height: 125,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Scrollbar(
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _defaultFoodItems.length,
                          separatorBuilder: (context, i) =>
                              const Divider(height: 12, thickness: 0.5),
                          itemBuilder: (context, itemIndex) {
                            final item = _defaultFoodItems[itemIndex];
                            return foodDetailRow(
                              item.quantity,
                              item.name,
                              item.price,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Pickup Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.storefront,
                          size: 18,
                          color: ThemesColors.darkCharcoal,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.pickupLocation,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ThemesColors.darkCharcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Drop Off Location
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: ThemesColors.darkCharcoal,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            order.dropOffLocation,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ThemesColors.darkCharcoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),

                    // Earning Money Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Earning:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: ThemesColors.darkCharcoal,
                          ),
                        ),
                        Text(
                          order.earningAmount,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ThemesColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Show View Route Button if Accepted, else show Decline and Accept
                    if (isAccepted) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemesColors.brandOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // Set primary active delivery number!
                                ActiveDeliveryState.currentDeliveryNumber = deliveryId;

                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.riderMaps,
                                  arguments: deliveryId,
                                );
                              },
                              icon: const Icon(
                                Icons.alt_route_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "View Route",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Arrived Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemesColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isLoading ? null : () => _showArrivedConfirmationDialog(context, deliveryId, order),
                            child: isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Arrived",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          // Decline Button with Loading Spinner
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: ThemesColors.error,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : () => _handleDecline(deliveryId),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: ThemesColors.error,
                                      ),
                                    )
                                  : const Text(
                                      "Decline",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ThemesColors.darkCharcoal,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Accept Button with Loading Spinner
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: ThemesColors.darkCharcoal,
                                foregroundColor: ThemesColors.success,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: isLoading ? null : () => _handleAccept(deliveryId),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Accept",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Alias for backwards compatibility
typedef orderDetail = OrderDetail;
