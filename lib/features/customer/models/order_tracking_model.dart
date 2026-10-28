import 'package:flutter/foundation.dart';

// 4 Transparent operational dispatch stages
enum OrderTrackingStage {
  confirmed(
    stepNumber: 1,
    headerTitle: 'Confirmed',
    pipelineTitle: '1. Order Confirmed',
    defaultStatusText: 'Order received. Kitchen has queued your ticket for prep.',
  ),
  preparing(
    stepNumber: 2,
    headerTitle: 'Preparing',
    pipelineTitle: '2. Kitchen Preparing',
    defaultStatusText: 'Kitchen is packing your dish. Rider dispatched upon packaging completion.',
  ),
  almostDone(
    stepNumber: 3,
    headerTitle: 'On the Way',
    pipelineTitle: '3. On the Way',
    defaultStatusText: 'Dishes boxed! Rider picked up order and is navigating to your location.',
  ),
  delivered(
    stepNumber: 4,
    headerTitle: 'Delivered',
    pipelineTitle: '4. Delivered',
    defaultStatusText: 'Order has been delivered!',
  );

  final int stepNumber;
  final String headerTitle;
  final String pipelineTitle;
  final String defaultStatusText;

  const OrderTrackingStage({
    required this.stepNumber,
    required this.headerTitle,
    required this.pipelineTitle,
    required this.defaultStatusText,
  });

  String get stageBadge => 'Stage $stepNumber/4 • $headerTitle';
}

/// Point A to Point B Hyper-Local Corridor Route metadata.
@immutable
class CorridorRouteModel {
  final String merchantName;
  final String merchantHub;
  final String dropOffLandmark;
  final String destinationHub;
  final double distanceKm;
  final int etaMinutes;
  final bool isDirectUnstacked;

  const CorridorRouteModel({
    required this.merchantName,
    required this.merchantHub,
    required this.dropOffLandmark,
    required this.destinationHub,
    required this.distanceKm,
    required this.etaMinutes,
    this.isDirectUnstacked = true,
  });

  CorridorRouteModel copyWith({
    String? merchantName,
    String? merchantHub,
    String? dropOffLandmark,
    String? destinationHub,
    double? distanceKm,
    int? etaMinutes,
    bool? isDirectUnstacked,
  }) {
    return CorridorRouteModel(
      merchantName: merchantName ?? this.merchantName,
      merchantHub: merchantHub ?? this.merchantHub,
      dropOffLandmark: dropOffLandmark ?? this.dropOffLandmark,
      destinationHub: destinationHub ?? this.destinationHub,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      isDirectUnstacked: isDirectUnstacked ?? this.isDirectUnstacked,
    );
  }
}

/// Assigned Courier Profile & Vehicle Telemetry.
@immutable
class CourierProfileModel {
  final String name;
  final String plateNumber;
  final String vehicleType;
  final String phoneNumber;
  final String hubAffiliation;

  const CourierProfileModel({
    required this.name,
    required this.plateNumber,
    required this.vehicleType,
    required this.phoneNumber,
    required this.hubAffiliation,
  });

  String get displayNameWithPlate => '$name ($plateNumber)';
}

/// Drop-Off Proof-of-Delivery Record (Synchronized with Rider r_05 Wireframe).
@immutable
class DropOffProofModel {
  final String fileName;
  final String caption;
  final String timestampFormatted;
  final String gpsAccuracyTag;
  final String subPinLandmark;
  final String courierHandoffName;
  final String resolutionStatus;
  final String? localImageAsset;

  const DropOffProofModel({
    required this.fileName,
    required this.caption,
    required this.timestampFormatted,
    required this.gpsAccuracyTag,
    required this.subPinLandmark,
    required this.courierHandoffName,
    required this.resolutionStatus,
    this.localImageAsset,
  });
}

/// Individual item in the 4-stage vertical pipeline stepper.
@immutable
class TrackingMilestoneModel {
  final int stageIndex;
  final String title;
  final String subtitle;
  final String? completedTimestamp;

  const TrackingMilestoneModel({
    required this.stageIndex,
    required this.title,
    required this.subtitle,
    this.completedTimestamp,
  });
}

/// Master Entity representing live tracking state for Tab 2.
@immutable
class OrderTrackingModel {
  final String orderId;
  final OrderTrackingStage currentStage;
  final String etaTimeDisplay;
  final int etaMinutesRemaining;
  final String etaBadgeLabel;
  final String stageDescription;
  final bool is100mBeaconActive;
  final String residenceLabel;
  final CorridorRouteModel corridor;
  final CourierProfileModel courier;
  final DropOffProofModel dropOffProof;
  final List<TrackingMilestoneModel> milestones;

  const OrderTrackingModel({
    required this.orderId,
    required this.currentStage,
    required this.etaTimeDisplay,
    required this.etaMinutesRemaining,
    required this.etaBadgeLabel,
    required this.stageDescription,
    required this.is100mBeaconActive,
    required this.residenceLabel,
    required this.corridor,
    required this.courier,
    required this.dropOffProof,
    required this.milestones,
  });

  OrderTrackingModel copyWith({
    String? orderId,
    OrderTrackingStage? currentStage,
    String? etaTimeDisplay,
    int? etaMinutesRemaining,
    String? etaBadgeLabel,
    String? stageDescription,
    bool? is100mBeaconActive,
    String? residenceLabel,
    CorridorRouteModel? corridor,
    CourierProfileModel? courier,
    DropOffProofModel? dropOffProof,
    List<TrackingMilestoneModel>? milestones,
  }) {
    return OrderTrackingModel(
      orderId: orderId ?? this.orderId,
      currentStage: currentStage ?? this.currentStage,
      etaTimeDisplay: etaTimeDisplay ?? this.etaTimeDisplay,
      etaMinutesRemaining: etaMinutesRemaining ?? this.etaMinutesRemaining,
      etaBadgeLabel: etaBadgeLabel ?? this.etaBadgeLabel,
      stageDescription: stageDescription ?? this.stageDescription,
      is100mBeaconActive: is100mBeaconActive ?? this.is100mBeaconActive,
      residenceLabel: residenceLabel ?? this.residenceLabel,
      corridor: corridor ?? this.corridor,
      courier: courier ?? this.courier,
      dropOffProof: dropOffProof ?? this.dropOffProof,
      milestones: milestones ?? this.milestones,
    );
  }

// Static preset fixtures
  static const CorridorRouteModel defaultCorridor = CorridorRouteModel(
    merchantName: 'Bai Wei Mini Bowl',
    merchantHub: 'C180 Commercial Hub',
    dropOffLandmark: 'Gate Pillar 2 (Table)',
    destinationHub: 'Traders Square',
    distanceKm: 0.6,
    etaMinutes: 7,
    isDirectUnstacked: true,
  );

  // Custom Rider Example 1
  static const CourierProfileModel courierHarith = CourierProfileModel(
    name: 'Muhammad Harith',
    plateNumber: 'BQK 4812',
    vehicleType: 'Yamaha Y15ZR',
    phoneNumber: '+60 12-481 2940',
    hubAffiliation: 'Cheras Courier Direct Fleet',
  );

  // Custom Rider Example 2
  static const CourierProfileModel courierAriff = CourierProfileModel(
    name: 'Ariff Izzan',
    plateNumber: 'VDE 8891',
    vehicleType: 'Honda RS150R',
    phoneNumber: '+60 17-293 8812',
    hubAffiliation: 'Cyberjaya Fleet',
  );

  static const DropOffProofModel defaultProof = DropOffProofModel(
    fileName: 'gate_pillar_2_drop_verified.jpg',
    caption: 'Bag placed cleanly on guardhouse pillar drop table',
    timestampFormatted: '2026-10-27 12:44:18 MYT',
    gpsAccuracyTag: 'GPS Verified <5m',
    subPinLandmark: 'Cheras Traders Sq • Block B Gate',
    courierHandoffName: 'Muhammad Harith (BQK 4812)',
    resolutionStatus: 'Direct Unstacked Delivered',
  );

  static const List<TrackingMilestoneModel> standardMilestones = <TrackingMilestoneModel>[
    TrackingMilestoneModel(
      stageIndex: 1,
      title: '1. Order Confirmed',
      subtitle: 'Merchant acknowledged receipt & queued ticket.',
      completedTimestamp: '12:32 PM',
    ),
    TrackingMilestoneModel(
      stageIndex: 2,
      title: '2. Live Kitchen Preparing',
      subtitle: 'Dishes cooking on wok; portion counters deducted.',
    ),
    TrackingMilestoneModel(
      stageIndex: 3,
      title: '3. Almost Done (Rider Dispatched)',
      subtitle: 'Courier arriving at kitchen for bag pickup.',
    ),
    TrackingMilestoneModel(
      stageIndex: 4,
      title: '4. Delivered (Gate Drop Verified)',
      subtitle: 'Verified with GPS drop-off photo proof at Gate Pillar 2.',
    ),
  ];

  /// Preset 1: Stage 1/4 - Confirmed (Order Logged)
  static const OrderTrackingModel mockStage1 = OrderTrackingModel(
    orderId: 'E2E-89241',
    currentStage: OrderTrackingStage.confirmed,
    etaTimeDisplay: '12:50 PM',
    etaMinutesRemaining: 14,
    etaBadgeLabel: 'Order Logged',
    stageDescription: 'Order received. Kitchen has queued the ticket for wok prep.',
    is100mBeaconActive: false,
    residenceLabel: 'Landed Villa',
    corridor: defaultCorridor,
    courier: courierHarith,
    dropOffProof: defaultProof,
    milestones: standardMilestones,
  );

  /// Preset 2: Stage 2/4 - Preparing (On Schedule)
  static const OrderTrackingModel mockStage2 = OrderTrackingModel(
    orderId: 'E2E-89241',
    currentStage: OrderTrackingStage.preparing,
    etaTimeDisplay: '12:45 PM',
    etaMinutesRemaining: 8,
    etaBadgeLabel: 'On Schedule',
    stageDescription: 'Kitchen is packing your bowls. Rider dispatched upon packaging completion.',
    is100mBeaconActive: false,
    residenceLabel: 'Landed Villa',
    corridor: defaultCorridor,
    courier: courierHarith,
    dropOffProof: defaultProof,
    milestones: standardMilestones,
  );

  /// Preset 3: Stage 3/4 - On the Way (Rider in Transit + 100m Beacon Triggered)
  static const OrderTrackingModel mockStage3 = OrderTrackingModel(
    orderId: 'E2E-89241',
    currentStage: OrderTrackingStage.almostDone,
    etaTimeDisplay: '12:40 PM',
    etaMinutesRemaining: 3,
    etaBadgeLabel: 'Rider In Transit',
    stageDescription: 'Dishes boxed! Rider picked up order and is navigating to your location.',
    is100mBeaconActive: true,
    residenceLabel: 'Landed Villa',
    corridor: defaultCorridor,
    courier: courierHarith,
    dropOffProof: defaultProof,
    milestones: standardMilestones,
  );

  /// Preset 4: Stage 4/4 - Delivered (Completed)
  static const OrderTrackingModel mockStage4 = OrderTrackingModel(
    orderId: 'E2E-89241',
    currentStage: OrderTrackingStage.delivered,
    etaTimeDisplay: '12:44 PM',
    etaMinutesRemaining: 0,
    etaBadgeLabel: 'Delivered',
    stageDescription: 'Package dropped safely on Gate Pillar 2 drop table. Photo proof logged.',
    is100mBeaconActive: false,
    residenceLabel: 'Landed Villa',
    corridor: defaultCorridor,
    courier: courierHarith,
    dropOffProof: defaultProof,
    milestones: standardMilestones,
  );
}



// MINUTE-BASED ETA CALCULATOR

class EtaCalculator {
  /// Realistic urban motorcycle speed in Cheras / Cyberjaya (~3 mins per km)
  /// + 2 minutes fixed buffer for traffic lights & guardhouse registration.
  static int calculateTransitMinutes(double distanceKm) {
    const double minutesPerKm = 3.0;
    const int bufferMinutes = 2;
    final int transitMinutes = ((distanceKm * minutesPerKm) + bufferMinutes).round();
    return transitMinutes.clamp(2, 25); // Between 2 to 25 minutes
  }

  /// Calculates total order ETA: Kitchen Prep + Road Transit
  static int calculateTotalEtaMinutes({
    required double distanceKm,
    int kitchenPrepMinutes = 5,
  }) {
    return kitchenPrepMinutes + calculateTransitMinutes(distanceKm);
  }
}