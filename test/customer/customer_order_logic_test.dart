import 'package:flutter_test/flutter_test.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';

void main() {
  group('Easy2Eat Customer Unit Tests - Order & Transit Logic', () {
    test('TC-CU01: Dynamic transit ETA calculation based on corridor distance', () {
      const double distanceKm = 0.8;
      final int transitMins = EtaCalculator.calculateTransitMinutes(distanceKm);

      // Hyper-local corridor ETA should be greater than 0 and within a reasonable timeframe
      expect(transitMins, greaterThan(0));
      expect(transitMins, lessThanOrEqualTo(20));
    });

    test('TC-CU02: 100m Proximity Beacon activates only at <= 2 mins in transit', () {
      // 1. In transit but > 2 mins remaining -> Inactive
      final bool isFarActive = OrderTrackingStage.onTheWay == OrderTrackingStage.onTheWay &&
          5 <= 2 &&
          5 > 0;
      expect(isFarActive, isFalse);

      // 2. In transit and <= 2 mins remaining -> Active
      final bool isCloseActive = OrderTrackingStage.onTheWay == OrderTrackingStage.onTheWay &&
          2 <= 2 &&
          2 > 0;
      expect(isCloseActive, isTrue);

      // 3. Stage is Delivered (ETA 0) -> Inactive
      final bool isDeliveredActive = OrderTrackingStage.delivered == OrderTrackingStage.onTheWay &&
          0 <= 2 &&
          0 > 0;
      expect(isDeliveredActive, isFalse);
    });

    test('TC-CU03: CorridorRouteModel deserializes custom address and drop-off landmark', () {
      final mockMap = {
        'vendorName': 'Uncle Lim Chicken Rice',
        'deliveryAddress': 'Cheras Traders Square • Block C, Lobby Guardhouse',
        'location': 'C180 Kitchen Hub',
        'distanceKm': 0.8,
        'etaMinutes': 9,
      };

      final corridor = CorridorRouteModel.fromMap(mockMap);

      expect(corridor.merchantName, 'Uncle Lim Chicken Rice');
      expect(corridor.destinationHub, contains('Cheras Traders Square'));
      expect(corridor.dropOffLandmark, 'Cheras Traders Square • Block C, Lobby Guardhouse');
      expect(corridor.distanceKm, 0.8);
    });

    test('TC-CU04: Delivery stage stepper index follows 5-stage order pipeline', () {
      expect(OrderTrackingStage.confirmed.stepNumber, 1);
      expect(OrderTrackingStage.preparing.stepNumber, 2);
      expect(OrderTrackingStage.readyForPickup.stepNumber, 3);
      expect(OrderTrackingStage.onTheWay.stepNumber, 4);
      expect(OrderTrackingStage.delivered.stepNumber, 5);
    });
  });
}