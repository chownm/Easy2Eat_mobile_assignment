import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/active_delivery.dart';
import '../../../../core/constants/user_session.dart';
import '../../../../core/routing/RiderRouting.dart';
import '../../../../core/theme/theme.dart';
import 'models/delivery_order_model.dart';
import 'widgets/delivery_proof_options_sheet.dart';
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

    final myUid = UserSession.currentUid ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      // Fetch rider's personal declined orders so they remain hidden only for this rider
      if (myUid.isNotEmpty) {
        final declinedSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(myUid)
            .collection('declined_orders')
            .get();
        for (final doc in declinedSnapshot.docs) {
          _globalDeclinedOrders.add(doc.id);
        }
      }

      final snapshot = await FirebaseFirestore.instance.collection('orders').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => DeliveryOrderData.fromMap(doc.data(), doc.id))
            .where((order) => order.status != 'delivered' && !order.isDelivered)
            .toList();
      }
    } catch (_) {}

    return [];
  }

  /// Empty default list (100% real Firestore food data used)
  List<FoodItemData> get _defaultFoodItems => const [];

  Future<void> _handleAccept(String deliveryId) async {
    setState(() {
      _loadingOrderIds.add(deliveryId);
    });

    try {
      final myUid = UserSession.currentUid ?? FirebaseAuth.instance.currentUser?.uid;
      String? riderName = FirebaseAuth.instance.currentUser?.displayName;
      String? riderPhone = FirebaseAuth.instance.currentUser?.phoneNumber;

      // Fetch rider profile details from Firestore
      if (myUid != null && myUid.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(myUid).get();
        if (userDoc.exists && userDoc.data() != null) {
          riderName = userDoc.data()?['name'] as String? ?? riderName;
          riderPhone = userDoc.data()?['phone'] as String? ??
              userDoc.data()?['customerPhone'] as String? ??
              riderPhone;
        }
      }

      // Update Firestore directly (riderName & riderPhone can be null)
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(deliveryId)
          .set({
        'isAccepted': true,
        'assignedRiderId': myUid,
        'riderName': riderName,
        'riderPhone': riderPhone,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
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
      final myUid = UserSession.currentUid;
      if (myUid != null && myUid.isNotEmpty) {
        // Save to rider's personal declined_orders subcollection in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(myUid)
            .collection('declined_orders')
            .doc(deliveryId)
            .set({
          'declinedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: DeliveryProofOptionsSheet(
            deliveryId: deliveryId,
            onConfirmed: (proofUrl) async {
              await _completeDeliveryWithProof(deliveryId, order, proofUrl);
            },
          ),
        );
      },
    );
  }

  Future<void> _completeDeliveryWithProof(
      String deliveryId, DeliveryOrderData order, String proofUrl) async {
    setState(() {
      _loadingOrderIds.add(deliveryId);
    });

    try {
      final uid = UserSession.currentUid ?? 'guest_rider';
      final now = TimeOfDay.now();
      final currentTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // 1. Update order status and proofUrl in Firestore
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(deliveryId)
          .set({
        'status': 'delivered',
        'isDelivered': true,
        'proofUrl': proofUrl,
        'deliveredAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // 2. Send "Food is Delivered" message to customer_chats/{deliveryId}/messages
      await FirebaseFirestore.instance
          .collection('customer_chats')
          .doc(deliveryId)
          .collection('messages')
          .add({
        'message': 'Food is Delivered',
        'senderRole': 'rider',
        'senderUid': uid,
        'time': currentTime,
        'proofUrl': proofUrl,
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
          order.isDelivered = true;
          _globalDeclinedOrders.add(deliveryId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Delivery proof uploaded! "Food is Delivered" sent to customer.'),
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
    final myUid = UserSession.currentUid ?? '';

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
                (order.assignedRiderId == null ||
                    order.assignedRiderId!.isEmpty ||
                    order.assignedRiderId == myUid) &&
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
