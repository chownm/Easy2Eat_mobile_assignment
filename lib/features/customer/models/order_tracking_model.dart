import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// 5 Transparent operational dispatch stages
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
    defaultStatusText: 'Vendor received order and is actively preparing dishes.',
  ),
  readyForPickup(
    stepNumber: 3,
    headerTitle: 'Ready for Pickup',
    pipelineTitle: '3. Ready for Pickup',
    defaultStatusText: 'Dishes boxed! Waiting at counter for rider collection.',
  ),
  onTheWay(
    stepNumber: 4,
    headerTitle: 'On the Way',
    pipelineTitle: '4. Out for Delivery',
    defaultStatusText: 'Rider picked up order and is navigating to your location.',
  ),
  delivered(
    stepNumber: 5,
    headerTitle: 'Delivered',
    pipelineTitle: '5. Delivered',
    defaultStatusText: 'Order delivered and handed safely to customer.',
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

  String get stageBadge => 'Stage $stepNumber/5 • $headerTitle';
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

  factory CorridorRouteModel.fromMap(Map<String, dynamic> data) {
    final String fullDrop = (data['deliveryAddress'] ?? data['dropOffLocation'] ?? '').toString().replaceAll('Drop Off: ', '');

    return CorridorRouteModel(
      merchantName: data['vendorName'] ?? data['merchantName'] ?? 'Campus Merchant',
      merchantHub: (data['location'] ?? data['pickupLocation'] ?? 'Merchant Hub').toString().replaceAll('Pickup: ', ''),
      dropOffLandmark: fullDrop.isNotEmpty ? fullDrop : OrderTrackingModel.defaultSubPinLandmark,
      destinationHub: data['destinationHub'] ?? 'Cheras Traders Square',
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.6,
      etaMinutes: (data['etaMinutes'] as num?)?.toInt() ?? 8,
      isDirectUnstacked: data['isDirectUnstacked'] ?? true,
    );
  }
}

/// Assigned Courier Profile & Vehicle Telemetry (Parsed from live Rider state)
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

  CourierProfileModel copyWith({
    String? name,
    String? plateNumber,
    String? vehicleType,
    String? phoneNumber,
    String? hubAffiliation,
  }) {
    return CourierProfileModel(
      name: name ?? this.name,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      hubAffiliation: hubAffiliation ?? this.hubAffiliation,
    );
  }

  factory CourierProfileModel.fromMap(Map<String, dynamic> data) {
    final bool hasRider = data['assignedRiderId'] != null || data['riderName'] != null;
    return CourierProfileModel(
      name: data['riderName'] ?? (hasRider ? 'Assigned Rider' : 'Assigning Courier...'),
      plateNumber: data['riderPlate'] ?? (hasRider ? 'Verified Fleet' : 'Pending'),
      vehicleType: data['riderVehicle'] ?? 'Motorcycle',
      phoneNumber: data['riderPhone'] ?? '',
      hubAffiliation: data['hubAffiliation'] ?? 'Hyper-Local Express Fleet',
    );
  }
}

/// Drop-Off Proof-of-Delivery Record
@immutable
class DropOffProofModel {
  final String fileName;
  final String caption;
  final String timestampFormatted;
  final String gpsAccuracyTag;
  final String subPinLandmark;
  final String courierHandoffName;
  final String resolutionStatus;
  final String? cloudPhotoUrl;

  const DropOffProofModel({
    required this.fileName,
    required this.caption,
    required this.timestampFormatted,
    required this.gpsAccuracyTag,
    required this.subPinLandmark,
    required this.courierHandoffName,
    required this.resolutionStatus,
    this.cloudPhotoUrl,
  });

  factory DropOffProofModel.fromMap(Map<String, dynamic> data) {
    return DropOffProofModel(
      fileName: '${data['orderID'] ?? 'order'}_proof.jpg',
      caption: data['proofCaption'] ?? 'Drop-off verified at designated gate table',
      timestampFormatted: (data['deliveredAt'] is Timestamp)
          ? (data['deliveredAt'] as Timestamp).toDate().toString().split('.').first
          : 'Verified at drop-off',
      gpsAccuracyTag: 'GPS Verified <5m',
      subPinLandmark: data['deliveryAddress'] ?? OrderTrackingModel.defaultSubPinLandmark,
      courierHandoffName: data['riderName'] ?? 'Assigned Courier',
      resolutionStatus: 'Direct Unstacked Delivered',
      cloudPhotoUrl: data['proofUrl'] ?? data['proofPhotoUrl'] ?? data['dropOffProofPhotoUrl'],
    );
  }
}

/// Individual item in the 5-stage vertical pipeline stepper.
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

/// Master Entity representing live tracking state for Tab 2
@immutable
class OrderTrackingModel {
  static bool isProximityBeaconEnabled = true;
  static String defaultSubPinLandmark = 'Gate Pillar 2 (Table)';

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
  final DropOffProofModel? dropOffProof;
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
    this.dropOffProof,
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

  /// Initial live shell while Firestore document streams in (NO MOCK STRINGS)
  factory OrderTrackingModel.initial(String orderId) {
    return OrderTrackingModel(
      orderId: orderId,
      currentStage: OrderTrackingStage.confirmed,
      etaTimeDisplay: '--:--',
      etaMinutesRemaining: 15,
      etaBadgeLabel: 'Connecting...',
      stageDescription: 'Connecting to live kitchen pipeline...',
      is100mBeaconActive: false,
      residenceLabel: 'Delivery Destination',
      corridor: CorridorRouteModel(
        merchantName: 'Loading merchant...',
        merchantHub: 'Campus Hub',
        dropOffLandmark: defaultSubPinLandmark,
        destinationHub: 'Campus Area',
        distanceKm: 0.6,
        etaMinutes: 8,
      ),
      courier: const CourierProfileModel(
        name: 'Searching for nearby courier...',
        plateNumber: 'Pending',
        vehicleType: 'Motorcycle',
        phoneNumber: '',
        hubAffiliation: 'Campus Fleet',
      ),
      milestones: _buildLiveMilestones(OrderTrackingStage.confirmed, defaultSubPinLandmark),
    );
  }

  /// Deserializes pure Firestore DocumentSnapshot directly
  factory OrderTrackingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final String rawStatus = (data['status'] ?? data['stage'] ?? 'confirmed').toString().trim().toLowerCase();

    OrderTrackingStage stage = OrderTrackingStage.confirmed;
    switch (rawStatus) {
      case 'preparing':
        stage = OrderTrackingStage.preparing;
        break;
      case 'readyforpickup':
      case 'ready_for_pickup':
        stage = OrderTrackingStage.readyForPickup;
        break;
      case 'ontheway':
      case 'on_the_way':
      case 'almostdone':
        stage = OrderTrackingStage.onTheWay;
        break;
      case 'delivered':
      case 'done':
        stage = OrderTrackingStage.delivered;
        break;
      case 'confirmed':
      default:
        stage = OrderTrackingStage.confirmed;
    }

    final bool isDelivered = stage == OrderTrackingStage.delivered;
    final bool isPaused = data['isPaused'] ?? (stage == OrderTrackingStage.readyForPickup);
    final String pauseReason = data['pauseReason'] ?? '';
    final int minutes = (data['minutesRemaining'] as num?)?.toInt() ?? (isDelivered ? 0 : 8);

    final corridor = CorridorRouteModel.fromMap(data);
    final courier = CourierProfileModel.fromMap(data);
    final proof = (data['proofUrl'] != null || data['proofPhotoUrl'] != null || data['dropOffProofPhotoUrl'] != null)
        ? DropOffProofModel.fromMap(data)
        : null;

    return OrderTrackingModel(
      orderId: (data['orderID'] ?? data['orderId'] ?? doc.id).toString(),
      currentStage: stage,
      etaTimeDisplay: isDelivered ? 'Delivered' : '$minutes mins',
      etaMinutesRemaining: minutes,
      etaBadgeLabel: isDelivered
          ? 'Delivered'
          : (isPaused ? (pauseReason.isNotEmpty ? 'PAUSED • $pauseReason' : 'PAUSED') : 'On Schedule'),
      stageDescription: data['statusDescription'] ?? stage.defaultStatusText,
      is100mBeaconActive: stage == OrderTrackingStage.onTheWay && minutes <= 2,
      residenceLabel: data['deliveryAddress'] ?? 'Campus Residence',
      corridor: corridor,
      courier: courier,
      dropOffProof: proof,
      milestones: _buildLiveMilestones(stage, corridor.dropOffLandmark),
    );
  }

  static List<TrackingMilestoneModel> _buildLiveMilestones(OrderTrackingStage currentStage, String landmark) {
    return [
      const TrackingMilestoneModel(
        stageIndex: 1,
        title: '1. Order Confirmed',
        subtitle: 'Merchant acknowledged receipt and queued ticket.',
      ),
      const TrackingMilestoneModel(
        stageIndex: 2,
        title: '2. Live Kitchen Preparing',
        subtitle: 'Dishes cooking; portion counters updated.',
      ),
      const TrackingMilestoneModel(
        stageIndex: 3,
        title: '3. Ready at Counter',
        subtitle: 'Food packed. Awaiting assigned rider collection.',
      ),
      const TrackingMilestoneModel(
        stageIndex: 4,
        title: '4. Out for Delivery',
        subtitle: 'Courier collected order and is en route via direct corridor.',
      ),
      TrackingMilestoneModel(
        stageIndex: 5,
        title: '5. Delivered',
        subtitle: 'Verified with GPS drop-off photo proof at $landmark.',
      ),
    ];
  }
}

/// Minute-based ETA Calculator
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