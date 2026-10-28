import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/active_delivery.dart';
import '../../../../core/constants/user_session.dart';
import '../../../../core/routing/RiderRouting.dart';
import '../../../../core/theme/theme.dart';
import 'models/delivery_order_model.dart';
import 'widgets/empty_orders_view.dart';
import 'widgets/order_card_item.dart';

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

    // Return empty list so everything is based 100% on Firestore!
    return [];
  }

  /// Default mock food items for list preview using RM
  List<FoodItemData> get _defaultFoodItems => const [
        FoodItemData(quantity: 1, name: "Pizza", price: "RM10.00"),
        FoodItemData(quantity: 2, name: "Burger", price: "RM15.00"),
        FoodItemData(quantity: 1, name: "Spaghetti", price: "RM12.00"),
        FoodItemData(quantity: 2, name: "French Fries", price: "RM5.00"),
        FoodItemData(quantity: 1, name: "Coca-Cola", price: "RM2.50"),
      ];

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
          return EmptyOrdersView(onRefresh: resetOrders);
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

              return OrderCardItem(
                order: order,
                isAccepted: isAccepted,
                isLoading: isLoading,
                onAccept: () => _handleAccept(deliveryId),
                onDecline: () => _handleDecline(deliveryId),
                onViewRoute: () {
                  ActiveDeliveryState.currentDeliveryNumber = deliveryId;
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.riderMaps,
                    arguments: deliveryId,
                  );
                },
                onArrived: () => _showArrivedConfirmationDialog(context, deliveryId, order),
                defaultFoodItems: _defaultFoodItems,
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
