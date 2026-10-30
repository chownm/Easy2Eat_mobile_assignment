import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
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
import 'package:easy2eat/features/customer/models/customer_profile_model.dart';
import 'package:easy2eat/features/customer/settings/widgets/customer_profile_screen.dart';

class CustomerTrackingScreen extends StatefulWidget {
  final String orderId;

  const CustomerTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<CustomerTrackingScreen> createState() => _CustomerTrackingScreenState();
}

class _CustomerTrackingScreenState extends State<CustomerTrackingScreen> {
  // 3. Initialize dynamically later
  late OrderTrackingModel _order;

  // Minute-based simulation states
  bool _isPaused = false;
  String _pauseReason = '';
  Timer? _minuteTicker;
  StreamSubscription? _orderSub;

  final DraggableScrollableController _sheetController = DraggableScrollableController();
  static const double _minSheetExtent = 0.20;
  static const double _maxSheetExtent = 0.56;

  /// Formats the arrival clock time: e.g., DateTime.now() + 8 mins -> "12:48 PM"
  String _calculateEtaClockTime(int minutesRemaining) {
    final targetTime = DateTime.now().add(Duration(minutes: minutesRemaining));
    final int hour = targetTime.hour % 12 == 0 ? 12 : targetTime.hour % 12;
    final String minute = targetTime.minute.toString().padLeft(2, '0');
    final String period = targetTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Current time for delivery receipt: e.g. "12:44 PM"
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

    // Start at Stage 1 using the newly created Order ID
    _order = OrderTrackingModel.mockStage1.copyWith(
      orderId: widget.orderId,
    );

    final transitMins = EtaCalculator.calculateTransitMinutes(_order.corridor.distanceKm);
    final totalMins = 5 + transitMins;

    _order = _order.copyWith(
      etaMinutesRemaining: totalMins,
      etaTimeDisplay: _calculateEtaClockTime(totalMins),
      etaBadgeLabel: 'Order Logged',
    );

    _startMinuteTicker();
    _listenToCloudOrders();
  }

  @override
  void dispose() {
    _minuteTicker?.cancel();
    _orderSub?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  /// 1. MINUTE TICKER: Decrements 1 minute periodically when NOT paused
  void _startMinuteTicker() {
    _minuteTicker?.cancel();
    // For viva demo: drops 1 minute every 15 seconds
    _minuteTicker = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_isPaused || _order.etaMinutesRemaining <= 0) return;

      setState(() {
        final newMins = _order.etaMinutesRemaining - 1;
        final transitMins = EtaCalculator.calculateTransitMinutes(_order.corridor.distanceKm);

        // PAUSE POINT 1: Kitchen finished cooking -> Waiting for Vendor to confirm packed!
        if (_order.currentStage == OrderTrackingStage.preparing && newMins <= transitMins) {
          _isPaused = true;
          _pauseReason = 'Awaiting Kitchen';
          _order = _order.copyWith(
            etaMinutesRemaining: newMins,
            etaTimeDisplay: _calculateEtaClockTime(newMins),
            is100mBeaconActive: _order.currentStage == OrderTrackingStage.almostDone && newMins <= 2 && newMins > 0,
          );
          return;
        }

        _order = _order.copyWith(
          etaMinutesRemaining: newMins,
          etaTimeDisplay: _calculateEtaClockTime(newMins), // FIXED: Keeps clock time (e.g., "12:48 PM")
          is100mBeaconActive: _order.currentStage == OrderTrackingStage.almostDone && newMins <= 2 && newMins > 0,
        );
      });
    });
  }

  /// 2. LISTEN TO FIRESTORE: Reflects vendor/rider actions in real time
  void _listenToCloudOrders() {
    _orderSub = OrderSyncService.listenToOrder(_order.orderId)?.listen((doc) {
      if (!doc.exists || doc.data() == null) return;
      final data = doc.data()!;

      setState(() {
        final stageStr = data['stage'] ?? '';
        final bool isPaused = data['isPaused'] ?? false;
        final String pauseReason = data['pauseReason'] ?? '';
        final String desc = data['statusDescription'] ?? _order.stageDescription;
        final int? mins = data['minutesRemaining'];

        OrderTrackingStage newStage = _order.currentStage;
        if (stageStr == 'almostDone') newStage = OrderTrackingStage.almostDone;
        if (stageStr == 'delivered') newStage = OrderTrackingStage.delivered;

        final bool isOrderDelivered = newStage == OrderTrackingStage.delivered;
        final int currentMins = mins ?? _order.etaMinutesRemaining;
        final String clockTime = isOrderDelivered
            ? _getCurrentClockTime()
            : _calculateEtaClockTime(currentMins);

        _isPaused = isOrderDelivered ? false : isPaused;
        _pauseReason = isOrderDelivered ? '' : pauseReason;
        _order = _order.copyWith(
          currentStage: newStage,
          stageDescription: desc,
          etaMinutesRemaining: currentMins,
          etaTimeDisplay: clockTime,
          etaBadgeLabel: isOrderDelivered
              ? 'Delivered'
              : (isPaused ? 'PAUSED' : 'On Schedule'),
          is100mBeaconActive: newStage == OrderTrackingStage.almostDone && currentMins <= 2,
        );
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

  // MULTI-ROLE MILESTONE ACTIONS (VENDOR & RIDER CONFIRMATIONS)

  /// ACTION 1: Vendor logs in and confirms "Food Ready & Packed"
  void onVendorConfirmReady() {
    final transitMins = EtaCalculator.calculateTransitMinutes(_order.corridor.distanceKm);

    // 1. Sync to Firestore
    OrderSyncService.vendorConfirmFoodReady(_order.orderId, transitMins: transitMins);

    // 2. Local state update
    setState(() {
      // Moves to Stage 3 (Almost Done), but holds paused until Rider arrives!
      _isPaused = true;
      _pauseReason = 'Awaiting Rider Pickup';
      _order = _order.copyWith(
        currentStage: OrderTrackingStage.almostDone,
        etaMinutesRemaining: transitMins,
        etaTimeDisplay: _calculateEtaClockTime(transitMins), // Clock time
        etaBadgeLabel: 'PAUSED',
        stageDescription: 'Food packed! Courier arriving at store for pickup.',
      );
    });
  }

  /// ACTION 2: Rider arrives, verifies package & confirms "Picked Up"
  void onRiderConfirmPickup() {
    final transitMins = EtaCalculator.calculateTransitMinutes(_order.corridor.distanceKm);

    // 1. Sync to Firestore
    OrderSyncService.riderConfirmPickedUp(_order.orderId, _order.corridor.distanceKm);

    // 2. Local state update: RESUMES THE TIMER!
    setState(() {
      _isPaused = false;
      _pauseReason = '';
      _order = _order.copyWith(
        currentStage: OrderTrackingStage.almostDone,
        etaMinutesRemaining: transitMins,
        etaTimeDisplay: _calculateEtaClockTime(transitMins), // Clock time
        etaBadgeLabel: 'Rider En Route',
        stageDescription: 'Courier picked up order! On the way via direct corridor.',
        is100mBeaconActive: transitMins <= 2,
      );
    });
  }

  /// ACTION 3: Rider delivers at Gate Pillar 2 drop table
  void onRiderConfirmDelivered() {
    // 1. Sync to Firebase
    OrderSyncService.riderConfirmDelivered(_order.orderId);

    // 2. Local state update
    setState(() {
      _isPaused = false;
      _pauseReason = '';
      _minuteTicker?.cancel();

      final String deliveredTime = _getCurrentClockTime();

      _order = _order.copyWith(
        currentStage: OrderTrackingStage.delivered,
        etaMinutesRemaining: 0,
        etaTimeDisplay: deliveredTime, // Clock time: "12:44 PM"
        etaBadgeLabel: 'Delivered',
        stageDescription: 'Delivered safely to Gate Pillar 2 drop table. Photo proof logged.',
        is100mBeaconActive: false,
      );
    });
  }

  void _navigateToRiderChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatWindow(
          title: _order.courier.name,
          subtitle: '${_order.courier.plateNumber} • ${_order.courier.vehicleType}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Always sync the active corridor with the latest Sub-Pin set in Settings
    final activeCorridor = _order.corridor.copyWith(
      dropOffLandmark: OrderTrackingModel.defaultSubPinLandmark,
    );

    // 2. Dynamically update Milestone 4 text with the landmark
    final updatedMilestones = _order.milestones.map((m) {
      if (m.stageIndex == 4) {
        return TrackingMilestoneModel(
          stageIndex: m.stageIndex,
          title: m.title,
          subtitle: 'Verified with GPS drop-off photo proof at ${OrderTrackingModel.defaultSubPinLandmark}.',
          completedTimestamp: m.completedTimestamp,
        );
      }
      return m;
    }).toList();

    // Current sheet size tracking for smooth zero-bleed gating
    final double currentExtent =
    _sheetController.isAttached ? _sheetController.size : _minSheetExtent;
    final double expandProgress =
    ((currentExtent - _minSheetExtent) / (_maxSheetExtent - _minSheetExtent))
        .clamp(0.0, 1.0);
    final bool isExpanded = expandProgress > 0.05;
    final bool isDelivered = _order.currentStage == OrderTrackingStage.delivered;

    return Scaffold(
      backgroundColor: ThemesColors.appSurface,
      body: Stack(
        children: <Widget>[
          // LAYER 1: INTERACTIVE MAP VIEWPORT (Pan & Zoom Enabled)
          Positioned.fill(
            child: CustomerLiveTrackingMapView(
              corridor: activeCorridor,
              stage: _order.currentStage,
              etaMinutesRemaining: _order.etaMinutesRemaining,
              onRouteLoaded: (RouteInfo route) {
                final int dynamicTransitMins =
                EtaCalculator.calculateTransitMinutes(route.distanceKm);
                // Sync live distance & duration from Geoapify into your state!
                setState(() {
                  _order = _order.copyWith(
                    corridor: _order.corridor.copyWith(
                      distanceKm: route.distanceKm,
                      etaMinutes: dynamicTransitMins,
                    ),
                  );
                });
              },
            ),
          ),

          // LAYER 2: TOP FLOATING BAR & 100M BEACON ALERT
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
                  SharedCustomerTopBar(
                    title: 'Live Order Tracking',
                    subtitle:
                    'Order #${_order.orderId} • ${_order.currentStage.stageBadge}',
                    showPulseIndicator: true,
                    showBackButton: false,
                    showProfileButton: true,
                  ),
                  // Renders ONLY if the delivery milestone triggers it AND the user hasn't disabled it in Settings:
                  if (_order.is100mBeaconActive && OrderTrackingModel.isProximityBeaconEnabled)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: CustomerProximityBeaconBanner(
                        residenceLabel: _order.residenceLabel,
                        dropOffLandmark: activeCorridor.dropOffLandmark,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // LAYER 3: RESPONSIVE DRAGGABLE BOTTOM SHEET
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
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
                    // 1. Drag Handle Pill (Tap or Drag to Toggle)
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
                            color: ThemesColors.darkCharcoal.withValues(
                              alpha: 0.22,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 2. Component 1: Estimated Arrival Hero Card (always visible)
                    CustomerEstimatedArrivalHeroCard(
                      stage: _order.currentStage,
                      etaTimeDisplay: _order.etaTimeDisplay,
                      etaMinutesRemaining: _order.etaMinutesRemaining,
                      etaBadgeLabel: isDelivered
                          ? 'Delivered'
                          : (_isPaused ? 'PAUSED • $_pauseReason' : _order.etaBadgeLabel),
                      stageDescription: _order.stageDescription,
                    ),

                    // 3. Components 2 & 3: REVEALED ONLY WHEN PULLED UP
                    Visibility(
                      visible: isExpanded,
                      maintainState: true,
                      child: Opacity(
                        opacity: expandProgress,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const SizedBox(height: 15),

                            // Component 2: Sideways 4-Stage Stepper
                            CustomerStagePipelineStepper(
                              currentStage: _order.currentStage,
                              milestones: updatedMilestones,
                            ),

                            const SizedBox(height: 15),

                            // Component 3: Rider Card (Direct Chat Trigger)
                            CustomerCourierContactCard(
                              courier: _order.courier,
                              onChatWithRider: _navigateToRiderChat,
                            ),

                            const SizedBox(height: 30),

                            // Multi-Role Simulation Dock
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

  Widget _buildSimulationDock() {
    final bool isDelivered = _order.currentStage == OrderTrackingStage.delivered;

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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDelivered
                      ? Colors.blue.shade100
                      : (_isPaused ? Colors.amber.shade100 : Colors.green.shade100),
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
              // 1. Vendor Confirms Food Ready
              Expanded(
                child: ElevatedButton(
                  onPressed: isDelivered ? null : onVendorConfirmReady,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemesColors.darkCharcoal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('1. Vendor Ready', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 6),

              // 2. Rider Confirms Picked Up (Resumes Countdown!)
              Expanded(
                child: ElevatedButton(
                  onPressed: isDelivered ? null : onRiderConfirmPickup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemesColors.brandOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('2. Rider Pickup', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 6),

              // 3. Rider Confirms Delivered
              Expanded(
                child: ElevatedButton(
                  onPressed: isDelivered ? null : onRiderConfirmDelivered,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemesColors.freshGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('3. Delivered', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}