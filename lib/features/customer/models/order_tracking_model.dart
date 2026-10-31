import 'package:cloud_firestore/cloud_firestore.dart';
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
  /// Global preference toggle: Enable/disable 100m proximity alert chime & banner
  static bool isProximityBeaconEnabled = true;

  /// Global default drop-off sub-pin landmark (Configurable via Settings c_11)
  static String defaultSubPinLandmark = 'Gate Pillar 2 (Table)';

  // Vendor Flat Schema Fields (Synced with Firestore)
  final String orderId;
  final OrderTrackingStage currentStage;
  final String customerName;
  final String customerPhone;
  final double totalPrice;
  final String location;
  final String? assignedRiderId;
  final String? riderName;
  final String? riderPhone;
  final bool isPickedUp;

  // Local UI State Fields
  final String etaTimeDisplay;
  final int etaMinutesRemaining;
  final String etaBadgeLabel;
  final String stageDescription;
  final bool is100mBeaconActive;
  final String residenceLabel;
  final CorridorRouteModel corridor;
  final DropOffProofModel dropOffProof;
  final List<TrackingMilestoneModel> milestones;

  const OrderTrackingModel({
    required this.orderId,
    required this.currentStage,
    required this.customerName,
    required this.customerPhone,
    required this.totalPrice,
    required this.location,
    this.assignedRiderId,
    this.riderName,
    this.riderPhone,
    required this.isPickedUp,

    // UI Defaults
    this.etaTimeDisplay = '',
    this.etaMinutesRemaining = 0,
    this.etaBadgeLabel = '',
    this.stageDescription = '',
    this.is100mBeaconActive = false,
    this.residenceLabel = 'Landed Villa',
    this.corridor = defaultCorridor,
    this.dropOffProof = defaultProof,
    this.milestones = standardMilestones,
  });

  /// Bridges the Vendor's flat rider string fields into the UI's Courier Object
  CourierProfileModel get courier => CourierProfileModel(
    name: riderName ?? 'Assigned Courier',
    plateNumber: 'TBD',
    vehicleType: 'Motorcycle',
    phoneNumber: riderPhone ?? '',
    hubAffiliation: 'Platform Fleet',
  );

  /// Master parser for the shared pipeline document reading from Vendor's OrderModel[cite: 2].
  factory OrderTrackingModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};

    // 1. Safely map Vendor's string status to Customer enum
    final String rawStatus = data['status'] ?? 'pending';
    OrderTrackingStage parsedStage;
    switch (rawStatus) {
      case 'preparing':
        parsedStage = OrderTrackingStage.preparing;
        break;
      case 'almostDone':
        parsedStage = OrderTrackingStage.almostDone;
        break;
      case 'delivered':
      case 'done':
        parsedStage = OrderTrackingStage.delivered;
        break;
      case 'pending':
      default:
        parsedStage = OrderTrackingStage.confirmed;
    }

    return OrderTrackingModel(
      orderId: data['orderID'] ?? doc.id,
      currentStage: parsedStage,
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      location: data['location'] ?? '',
      assignedRiderId: data['assignedRiderId'],
      riderName: data['riderName'],
      riderPhone: data['riderPhone'],
      isPickedUp: data['isPickedUp'] ?? false,
      etaMinutesRemaining: (data['minutesRemaining'] as num?)?.toInt() ?? 0,
    );
  }

  OrderTrackingModel copyWith({
    String? orderId,
    OrderTrackingStage? currentStage,
    String? etaTimeDisplay,
    int? etaMinutesRemaining,
    String? etaBadgeLabel,
    String? stageDescription,
    bool? is100mBeaconActive,
    CorridorRouteModel? corridor,
  }) {
    return OrderTrackingModel(
      orderId: orderId ?? this.orderId,
      currentStage: currentStage ?? this.currentStage,
      customerName: customerName,
      customerPhone: customerPhone,
      totalPrice: totalPrice,
      location: location,
      assignedRiderId: assignedRiderId,
      riderName: riderName,
      riderPhone: riderPhone,
      isPickedUp: isPickedUp,
      etaTimeDisplay: etaTimeDisplay ?? this.etaTimeDisplay,
      etaMinutesRemaining: etaMinutesRemaining ?? this.etaMinutesRemaining,
      etaBadgeLabel: etaBadgeLabel ?? this.etaBadgeLabel,
      stageDescription: stageDescription ?? this.stageDescription,
      is100mBeaconActive: is100mBeaconActive ?? this.is100mBeaconActive,
      residenceLabel: residenceLabel,
      corridor: corridor ?? this.corridor,
      dropOffProof: dropOffProof,
      milestones: milestones,
    );
  }

  // STATIC PRESET FIXTURES (For UI renders and viva demonstration)

  static const CorridorRouteModel defaultCorridor = CorridorRouteModel(
    merchantName: 'Bai Wei Mini Bowl',
    merchantHub: 'C180 Commercial Hub',
    dropOffLandmark: 'Gate Pillar 2 (Table)',
    destinationHub: 'Traders Square',
    distanceKm: 0.6,
    etaMinutes: 7,
    isDirectUnstacked: true,
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

  static const OrderTrackingModel mockStage2 = OrderTrackingModel(
    orderId: 'E2E-89241',
    currentStage: OrderTrackingStage.preparing,
    customerName: 'Joel Ira',
    customerPhone: '+60 12-892 4118',
    totalPrice: 19.80,
    location: 'Gate Pillar 2 (Table)',
    isPickedUp: false,
    etaTimeDisplay: '12:45 PM',
    etaMinutesRemaining: 8,
    etaBadgeLabel: 'On Schedule',
    stageDescription: 'Kitchen is packing your bowls. Rider dispatched upon packaging completion.',
  );

  static const OrderTrackingModel mockStage1 = OrderTrackingModel(
    orderId: 'E2E-89241',
    currentStage: OrderTrackingStage.confirmed,
    customerName: 'Joel Ira',
    customerPhone: '+60 12-892 4118',
    totalPrice: 19.80,
    location: 'Gate Pillar 2 (Table)',
    isPickedUp: false,
    etaTimeDisplay: '14 mins',
    etaMinutesRemaining: 14,
    etaBadgeLabel: 'Order Logged',
    stageDescription: 'Order received. Kitchen has queued your ticket for prep.',
  );

  static const OrderTrackingModel mockStage3 = OrderTrackingModel(
    orderId: 'E2E-89241',
    currentStage: OrderTrackingStage.almostDone,
    customerName: 'Joel Ira',
    customerPhone: '+60 12-892 4118',
    totalPrice: 19.80,
    location: 'Gate Pillar 2 (Table)',
    isPickedUp: true,
    etaTimeDisplay: '3 mins',
    etaMinutesRemaining: 3,
    etaBadgeLabel: 'Rider In Transit',
    stageDescription: 'Dishes boxed! Rider picked up order and is navigating to your location.',
    is100mBeaconActive: true,
  );

  static const OrderTrackingModel mockStage4 = OrderTrackingModel(
    orderId: 'E2E-89241',
    currentStage: OrderTrackingStage.delivered,
    customerName: 'Joel Ira',
    customerPhone: '+60 12-892 4118',
    totalPrice: 19.80,
    location: 'Gate Pillar 2 (Table)',
    isPickedUp: true,
    etaTimeDisplay: 'Delivered',
    etaMinutesRemaining: 0,
    etaBadgeLabel: 'Delivered',
    stageDescription: 'Package dropped safely on Gate Pillar 2 drop table. Photo proof logged.',
  );
}

// 3. ETA CALCULATOR

class EtaCalculator {
  static int calculateTransitMinutes(double distanceKm) {
    const double minutesPerKm = 3.0;
    const int bufferMinutes = 2;
    final int transitMinutes = ((distanceKm * minutesPerKm) + bufferMinutes).round();
    return transitMinutes.clamp(2, 25);
  }

  static int calculateTotalEtaMinutes({
    required double distanceKm,
    int kitchenPrepMinutes = 5,
  }) {
    return kitchenPrepMinutes + calculateTransitMinutes(distanceKm);
  }
}
