import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/customer_shell_screen.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';
import 'package:easy2eat/features/customer/tracking/widgets/courier_contact_card.dart';
import 'package:easy2eat/features/customer/tracking/widgets/estimated_arrival_hero_card.dart';
import 'package:easy2eat/features/customer/tracking/widgets/live_tracking_map_view.dart';
import 'package:easy2eat/features/customer/tracking/widgets/proximity_beacon_banner.dart';
import 'package:easy2eat/features/customer/tracking/widgets/stage_pipeline_stepper.dart';
import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';
import 'package:easy2eat/services/maps/map_api_service.dart';
import 'package:easy2eat/shared/widgets/ChatWindow/ui.dart';
import 'package:easy2eat/services/orders/order_sync_service.dart';
import 'package:easy2eat/services/notification/notification_service.dart';


class CustomerTrackingScreen extends StatefulWidget {
  final String? orderId; // Optional: Can be null when opened from Bottom Nav Bar
  final bool showBackButton;

  const CustomerTrackingScreen({
    super.key,
    this.orderId,
    this.showBackButton = false,
  });

  @override
  State<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends State<CustomerTrackingScreen> {
  OrderTrackingModel? _order;
  bool _isLoading = true;
  String? _resolvedOrderId;
  // Track order ID to prevent spamming notifications on every stream pulse
  String? _lastNotified100mOrderId;

  // Multi-order list for active orders switcher
  List _activeOrders = [];
  List _allCustomerOrders = [];

  bool _isPaused = false;
  String _pauseReason = '';
  String? _assignedRiderId;
  String? _proofPhotoUrl;
  Timer? _minuteTicker;
  StreamSubscription? _orderSub;
  StreamSubscription? _userOrdersSub;

  final DraggableScrollableController _sheetController = DraggableScrollableController();
  static const double _minSheetExtent = 0.20;
  static const double _maxSheetExtent = 0.56;

  String _calculateEtaClockTime(int minutesRemaining) {
    final targetTime = DateTime.now().add(Duration(minutes: minutesRemaining));
    final int hour = targetTime.hour % 12 == 0 ? 12 : targetTime.hour % 12;
    final String minute = targetTime.minute.toString().padLeft(2, '0');
    final String period = targetTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _getCurrentClockTime() {
    final now = DateTime.now();
    final int hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final String minute = now.minute.toString().padLeft(2, '0');
    final String period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(() => setState(() {}));
    _initOrdersTrackingStream();
  }

  @override
  void didUpdateWidget(covariant CustomerTrackingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      if (widget.orderId != null && widget.orderId!.trim().isNotEmpty) {
        _switchOrder(widget.orderId!.trim());
      } else {
        _initOrdersTrackingStream();
      }
    }
  }
  @override
  void dispose() {
    _minuteTicker?.cancel();
    _orderSub?.cancel();
    _userOrdersSub?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  /// REAL-TIME ORDERS STREAM: Sorts Active from Delivered
  void _initOrdersTrackingStream() {
    final String? currentUid =
        FirebaseAuth.instance.currentUser?.uid ?? UserSession.currentUid;

    if (currentUid == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _userOrdersSub?.cancel();
    _userOrdersSub = FirebaseFirestore.instance
        .collection('orders')
        .where('customerID', isEqualTo: currentUid)
        .snapshots()
        .listen((querySnap) {
      final docs = querySnap.docs;

      final allList = [];
      final activeList = [];

      for (final doc in docs) {
      final data = doc.data();
      data['docId'] = doc.id;
      final rawStatus = (data['status'] ?? data['stage'] ?? '').toString().trim().toLowerCase();
      final bool isDelivered = data['isDelivered'] == true ||
      rawStatus == 'delivered' ||
      rawStatus == 'done';

      allList.add(data);
      if (!isDelivered) {
      activeList.add(data);
      }
      }

      if (!mounted) return;

      setState(() {
      _allCustomerOrders = allList;
      _activeOrders = activeList;
      });

      // Priority 1: Explicit order ID from constructor
      if (widget.orderId != null && widget.orderId!.trim().isNotEmpty && _resolvedOrderId == null) {
      _switchOrder(widget.orderId!.trim());
      return;
      }

      // Priority 2: If currently viewing an order that is still active, stay on it
      if (_resolvedOrderId != null &&
      _activeOrders.any((o) => (o['orderID'] ?? o['orderId'] ?? o['docId']) == _resolvedOrderId)) {
      return;
      }

      // Priority 3: Auto-switch to the newest ACTIVE order if available
      if (_activeOrders.isNotEmpty) {
      final latest = _activeOrders.last;
      final targetId = (latest['orderID'] ?? latest['orderId'] ?? latest['docId']).toString();
      _switchOrder(targetId);
      } else {
      // If NO active orders exist, and user hasn't explicitly chosen to inspect a historical order
      if (_resolvedOrderId == null) {
      setState(() {
      _order = null;
      _isLoading = false;
      });
      }
      }
    });
  }

  /// Switch the screen to track any order ID
  void _switchOrder(String orderId) {
    if (_resolvedOrderId == orderId && _order != null) return;

    setState(() {
      _resolvedOrderId = orderId;
      _isLoading = true;
      _lastNotified100mOrderId = null;
    });

    _order = OrderTrackingModel.initial(orderId);
    _startMinuteTicker();
    _listenToCloudOrders(orderId);
  }

  /// Dismiss the completed order from Tab 2
  void _dismissCurrentOrder() {
    _orderSub?.cancel();
    if (_activeOrders.isNotEmpty) {
      // If there's another active delivery, switch to it
      final nextOrder = _activeOrders.last;
      final targetId = (nextOrder['orderID'] ?? nextOrder['orderId'] ?? nextOrder['docId']).toString();
      _switchOrder(targetId);
    } else {
      // Otherwise navigate to Home feed
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerShellScreen(initialIndex: 0),
        ),
            (route) => false,
      );
    }
  }

  void _startMinuteTicker() {
    _minuteTicker?.cancel();
    _minuteTicker = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_order == null || _isPaused || _order!.etaMinutesRemaining <= 0) return;

      setState(() {
        final newMins = _order!.etaMinutesRemaining - 1;
        _order = _order!.copyWith(
          etaMinutesRemaining: newMins,
          etaTimeDisplay: _calculateEtaClockTime(newMins),
          is100mBeaconActive: _order!.currentStage == OrderTrackingStage.onTheWay &&
              newMins <= 2 &&
              newMins > 0,
        );

        _checkAndTrigger100mNotification();
      });
    });
  }

  void _checkAndTrigger100mNotification() {
    if (_order == null) return;

    final bool isBeaconActive = _order!.is100mBeaconActive ||
        (_order!.currentStage == OrderTrackingStage.onTheWay &&
            _order!.etaMinutesRemaining <= 2 &&
            _order!.etaMinutesRemaining > 0);

    if (isBeaconActive &&
        OrderTrackingModel.isProximityBeaconEnabled &&
        _lastNotified100mOrderId != _order!.orderId) {
      _lastNotified100mOrderId = _order!.orderId;

      NotificationService.showLocalNotification(
        title: '🚨 100m Proximity Alert • #${_order!.orderId}',
        body: 'Courier is within 100m! Head downstairs to ${_order!.corridor.dropOffLandmark} for pickup.',
      );
    }
  }

  void _listenToCloudOrders(String orderId) {
    _orderSub?.cancel();
    _orderSub = OrderSyncService.listenToOrder(orderId)?.listen((doc) {
      if (!doc.exists || doc.data() == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final data = doc.data()! as Map<String, dynamic>;

      setState(() {
        _order = OrderTrackingModel.fromFirestore(doc);
        _assignedRiderId = data['assignedRiderId'];
        _isPaused = data['isPaused'] ??
            (_order!.currentStage == OrderTrackingStage.readyForPickup);
        _pauseReason = data['pauseReason'] ?? (_isPaused ? 'Awaiting Rider Pickup' : '');
        _proofPhotoUrl = data['proofUrl'] ?? data['proofPhotoUrl'] ?? data['dropOffProofPhotoUrl'];

        if (_order!.currentStage == OrderTrackingStage.delivered) {
          _order = _order!.copyWith(
            etaTimeDisplay: _getCurrentClockTime(),
            etaBadgeLabel: 'Delivered',
          );
        } else {
          _order = _order!.copyWith(
            etaTimeDisplay: _calculateEtaClockTime(_order!.etaMinutesRemaining),
            etaBadgeLabel: _isPaused ? 'PAUSED • $_pauseReason' : 'On Schedule',
          );
        }
        _isLoading = false;

        _checkAndTrigger100mNotification();
      });
    });
  }

  void _toggleSheet() {
    if (!_sheetController.isAttached) return;
    final double target = _sheetController.size > _minSheetExtent + 0.1
        ? _minSheetExtent
        : _maxSheetExtent;
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// MODAL: Allows switching between ANY order directly from the tracking tab
  void _showOrderSwitcherSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemesColors.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.55,
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: ThemesColors.darkCharcoal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Order to Track',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ThemesColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_allCustomerOrders.length} total',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Flexible(
                child: _allCustomerOrders.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('No orders found.')),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _allCustomerOrders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _allCustomerOrders[index];
                    final String id =
                    (item['orderID'] ?? item['orderId'] ?? item['docId']).toString();
                    final String status =
                    (item['status'] ?? item['stage'] ?? 'Active').toString().toUpperCase();
                    final bool isDelivered = status == 'DELIVERED';
                    final bool isCurrentlySelected = id == _resolvedOrderId;

                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _switchOrder(id);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrentlySelected
                              ? ThemesColors.brandOrange.withValues(alpha: 0.08)
                              : ThemesColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrentlySelected
                                ? ThemesColors.brandOrange
                                : ThemesColors.darkCharcoal.withValues(alpha: 0.12),
                            width: isCurrentlySelected ? 1.6 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDelivered
                                  ? Icons.check_circle_rounded
                                  : Icons.delivery_dining_rounded,
                              color: isDelivered
                                  ? ThemesColors.freshGreen
                                  : ThemesColors.brandOrange,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #$id',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: ThemesColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    item['orderItems'] ?? 'Meal Order',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: ThemesColors.darkCharcoal
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDelivered
                                    ? ThemesColors.freshGreen.withValues(alpha: 0.12)
                                    : ThemesColors.brandOrange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isDelivered
                                      ? ThemesColors.freshGreen
                                      : ThemesColors.brandOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onVendorConfirmReady() {
    if (_resolvedOrderId == null || _order == null) return;
    final transitMins =
    EtaCalculator.calculateTransitMinutes(_order!.corridor.distanceKm);
    OrderSyncService.vendorConfirmFoodReady(_resolvedOrderId!,
        transitMins: transitMins);
  }

  void onRiderConfirmPickup() {
    if (_resolvedOrderId == null || _order == null) return;
    OrderSyncService.riderConfirmPickedUp(
        _resolvedOrderId!, _order!.corridor.distanceKm);
  }

  void onRiderConfirmDelivered() {
    if (_resolvedOrderId == null) return;
    OrderSyncService.riderConfirmDelivered(_resolvedOrderId!);
  }

  void _navigateToRiderChat() {
    if (_order == null) return;
    if (_assignedRiderId == null && _order!.courier.name.contains('Searching')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: ThemesColors.darkCharcoal,
          content: Text('Awaiting rider assignment before chat is enabled.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatWindow(
          title: _order!.courier.name,
          subtitle:
          '${_order!.courier.plateNumber} • ${_order!.courier.vehicleType}',
          chatRoomId: _order!.orderId,
          isCustomerView: true,
        ),
      ),
    );
  }

  void _showDropOffProofDialog(BuildContext context) {
    if (_order == null) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ThemesColors.appSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Drop-Off Verification Proof',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ThemesColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _proofPhotoUrl != null && _proofPhotoUrl!.isNotEmpty
                    ? Image.network(
                  _proofPhotoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ThemesColors.brandOrange,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                )
                    : Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: ThemesColors.darkCharcoal
                        .withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'No drop-off photo proof available yet.',
                      style: TextStyle(
                        color: ThemesColors.darkCharcoal,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Drop-Off: ${_order!.corridor.dropOffLandmark}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: ThemesColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Courier: ${_order!.courier.name}',
                style: TextStyle(
                  fontSize: 11,
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemesColors.brandOrange,
                  foregroundColor: ThemesColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Close Verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: ThemesColors.appSurface,
        body: Center(
          child: CircularProgressIndicator(color: ThemesColors.brandOrange),
        ),
      );
    }

    // EMPTY STATE: If customer has no active orders
    if (_order == null) {
      return Scaffold(
        backgroundColor: ThemesColors.appSurface,
        body: SafeArea(
          child: Column(
            children: [
              SharedCustomerTopBar(
                title: 'Live Order Tracking',
                showBackButton: widget.showBackButton,
                showPulseIndicator: false,
                showProfileButton: true,
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delivery_dining_outlined,
                          size: 72,
                          color: ThemesColors.darkCharcoal
                              .withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Active Deliveries',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ThemesColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CustomerShellScreen(initialIndex: 0),
                              ),
                                  (route) => false,
                            );
                          },
                          icon: const Icon(Icons.restaurant_menu_rounded, size: 18),
                          label: const Text('Browse Kitchen Dishes'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemesColors.brandOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final double currentExtent =
    _sheetController.isAttached ? _sheetController.size : _minSheetExtent;
    final double expandProgress =
    ((currentExtent - _minSheetExtent) / (_maxSheetExtent - _minSheetExtent))
        .clamp(0.0, 1.0);
    final bool isExpanded = expandProgress > 0.05;
    final bool isDelivered = _order!.currentStage == OrderTrackingStage.delivered;

    return Scaffold(
      backgroundColor: ThemesColors.appSurface,
      body: Stack(
        children: <Widget>[
          // LAYER 1: MAP VIEWPORT
          Positioned.fill(
            child: CustomerLiveTrackingMapView(
              corridor: _order!.corridor,
              stage: _order!.currentStage,
              etaMinutesRemaining: _order!.etaMinutesRemaining,
              onRouteLoaded: (RouteInfo route) {
                final int dynamicTransitMins =
                EtaCalculator.calculateTransitMinutes(route.distanceKm);
                setState(() {
                  _order = _order!.copyWith(
                    corridor: _order!.corridor.copyWith(
                      distanceKm: route.distanceKm,
                      etaMinutes: dynamicTransitMins,
                    ),
                  );
                });
              },
            ),
          ),

          // LAYER 2: TOP BAR, SWITCH BUTTON & BEACON
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      SharedCustomerTopBar(
                        title: 'Live Order Tracking',
                        subtitle: 'Order #${_order!.orderId} • ${_order!.currentStage.stageBadge}',
                        showPulseIndicator: !isDelivered,
                        showBackButton: widget.showBackButton,
                        showProfileButton: true,
                      ),
                      // Top Bar Order Switcher Pill
                      Positioned(
                        right: 64,
                        child: TextButton.icon(
                          onPressed: _showOrderSwitcherSheet,
                          icon: const Icon(Icons.swap_horiz_rounded, size: 16, color: ThemesColors.brandOrange),
                          label: const Text(
                            'Switch',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: ThemesColors.brandOrange,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: ThemesColors.brandOrange.withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // MULTI-ORDER SWITCHER BAR: If multiple active orders are ongoing
                  _buildMultiOrderSwitcherBar(),

                  if (_order!.is100mBeaconActive && OrderTrackingModel.isProximityBeaconEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: CustomerProximityBeaconBanner(
                        residenceLabel: _order!.residenceLabel,
                        dropOffLandmark: _order!.corridor.dropOffLandmark,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // LAYER 3: RESPONSIVE BOTTOM SHEET
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _minSheetExtent,
            minChildSize: _minSheetExtent,
            maxChildSize: _maxSheetExtent,
            snap: true,
            snapSizes: const <double>[_minSheetExtent, _maxSheetExtent],
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: ThemesColors.appSurface,
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
                  border: Border.all(
                    color: ThemesColors.darkCharcoal.withValues(alpha: 0.1),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 16),
                  physics: const ClampingScrollPhysics(),
                  children: <Widget>[
                    InkWell(
                      onTap: _toggleSheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        alignment: Alignment.center,
                        child: Container(
                          width: 38,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: ThemesColors.darkCharcoal
                                .withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    CustomerEstimatedArrivalHeroCard(
                      stage: _order!.currentStage,
                      etaTimeDisplay: _order!.etaTimeDisplay,
                      etaMinutesRemaining: _order!.etaMinutesRemaining,
                      etaBadgeLabel: isDelivered
                          ? 'Delivered'
                          : (_isPaused
                          ? 'PAUSED • $_pauseReason'
                          : _order!.etaBadgeLabel),
                      stageDescription: _order!.stageDescription,
                    ),

                    Visibility(
                      visible: isExpanded,
                      maintainState: true,
                      child: Opacity(
                        opacity: expandProgress,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(height: 15),

                            CustomerStagePipelineStepper(
                              currentStage: _order!.currentStage,
                              milestones: _order!.milestones,
                            ),

                            const SizedBox(height: 15),

                            CustomerCourierContactCard(
                              courier: _order!.courier,
                              onChatWithRider: _navigateToRiderChat,
                            ),

                            if (isDelivered ||
                                (_proofPhotoUrl != null &&
                                    _proofPhotoUrl!.isNotEmpty)) ...[
                              const SizedBox(height: 14),
                              _buildProofActionCard(),
                            ],

                            // ESCAPE ACTION: If delivered, show "Finish & Order Again"
                            if (isDelivered) ...[
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: _dismissCurrentOrder,
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                label: const Text('Finish & Order More Food'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ThemesColors.brandOrange,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 44),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            _buildSimulationDock(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Interactive Chip Bar allowing seamless switching between active tickets
  Widget _buildMultiOrderSwitcherBar() {
    if (_activeOrders.length <= 1) return const SizedBox.shrink();

    return Container(
      height: 38,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _activeOrders.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final ord = _activeOrders[index];
          final String id = (ord['orderID'] ?? ord['orderId'] ?? ord['docId']).toString();
          final String rawStatus = (ord['status'] ?? ord['stage'] ?? 'Active').toString().toUpperCase();
          final bool isCurrent = id == _resolvedOrderId;

          return Material(
            color: isCurrent ? ThemesColors.brandOrange : ThemesColors.appSurface,
            borderRadius: BorderRadius.circular(20),
            elevation: isCurrent ? 2 : 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _switchOrder(id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCurrent
                        ? ThemesColors.brandOrange
                        : ThemesColors.darkCharcoal.withValues(alpha: 0.18),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent ? Colors.white : ThemesColors.brandOrange,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '#$id • $rawStatus',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isCurrent ? Colors.white : ThemesColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProofActionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ThemesColors.freshGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemesColors.freshGreen.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            color: ThemesColors.freshGreen,
            size: 22,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drop-Off Verification Logged',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: ThemesColors.textPrimary,
                  ),
                ),
                Text(
                  'Photographic proof at gate pillar available',
                  style: TextStyle(
                    fontSize: 11,
                    color: ThemesColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showDropOffProofDialog(context),
            style: TextButton.styleFrom(
              backgroundColor: ThemesColors.freshGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'View Photo',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationDock() {
    final bool isDelivered =
        _order!.currentStage == OrderTrackingStage.delivered;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemesColors.darkCharcoal.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ROLE SIMULATION CONTROLS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: ThemesColors.darkCharcoal,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDelivered
                      ? Colors.blue.shade100
                      : (_isPaused
                      ? Colors.amber.shade100
                      : Colors.green.shade100),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isDelivered
                      ? 'COMPLETED'
                      : (_isPaused ? 'TIMER PAUSED' : 'COUNTING DOWN'),
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: isDelivered
                        ? Colors.blue.shade900
                        : (_isPaused ? Colors.brown : Colors.green.shade900),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isDelivered ? null : onVendorConfirmReady,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemesColors.darkCharcoal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('1. Vendor Ready',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: isDelivered ? null : onRiderConfirmPickup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemesColors.brandOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('2. Rider Pickup',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ElevatedButton(
                  onPressed: isDelivered ? null : onRiderConfirmDelivered,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemesColors.freshGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('3. Delivered',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}