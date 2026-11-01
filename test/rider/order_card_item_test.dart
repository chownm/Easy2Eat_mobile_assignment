import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy2eat/features/rider/presentation/RiderHomePage/models/delivery_order_model.dart';
import 'package:easy2eat/features/rider/presentation/RiderHomePage/widgets/order_card_item.dart';

void main() {
  final testOrder = DeliveryOrderData(
    deliveryId: "Delivery #0001",
    orderTime: "12:45 PM, 26 Oct",
    pickupLocation: "Pickup: Kuala Lumpur",
    dropOffLocation: "Drop Off: Jalan Tun",
    earningAmount: "RM12.50",
    status: 'pending',
    isDelivered: false,
    foodItems: const [
      FoodItemData(quantity: 1, name: "Pizza", price: "RM10.00"),
      FoodItemData(quantity: 2, name: "Burger", price: "RM15.00"),
    ],
  );

  final testFoodItems = const [
    FoodItemData(quantity: 1, name: "Pizza", price: "RM10.00"),
    FoodItemData(quantity: 2, name: "Burger", price: "RM15.00"),
  ];

  Widget createWidgetUnderTest({
    bool isAccepted = false,
    bool isLoading = false,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
    VoidCallback? onViewRoute,
    VoidCallback? onArrived,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: OrderCardItem(
            order: testOrder,
            isAccepted: isAccepted,
            isLoading: isLoading,
            onAccept: onAccept ?? () {},
            onDecline: onDecline ?? () {},
            onViewRoute: onViewRoute ?? () {},
            onArrived: onArrived ?? () {},
            defaultFoodItems: testFoodItems,
          ),
        ),
      ),
    );
  }

  group('OrderCardItem Widget Tests', () {
    testWidgets('Renders order details and Accept/Decline buttons when unaccepted',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify header details
      expect(find.text("Delivery #0001"), findsOneWidget);
      expect(find.text("12:45 PM, 26 Oct"), findsOneWidget);

      // Verify locations
      expect(find.text("Pickup: Kuala Lumpur"), findsOneWidget);
      expect(find.text("Drop Off: Jalan Tun"), findsOneWidget);

      // Verify earning
      expect(find.text("Earning:"), findsOneWidget);
      expect(find.text("RM12.50"), findsOneWidget);

      // Verify Accept and Decline buttons are shown
      expect(find.text("Accept"), findsOneWidget);
      expect(find.text("Decline"), findsOneWidget);

      // Verify ACCEPTED badge and View Route button are not shown
      expect(find.text("ACCEPTED"), findsNothing);
      expect(find.text("View Route"), findsNothing);
    });

    testWidgets('Renders ACCEPTED badge and View Route / Arrived buttons when accepted',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(isAccepted: true));

      // Verify ACCEPTED badge is visible
      expect(find.text("ACCEPTED"), findsOneWidget);

      // Verify View Route and Arrived buttons are visible
      expect(find.text("View Route"), findsOneWidget);
      expect(find.text("Arrived"), findsOneWidget);

      // Verify Accept and Decline buttons are not visible
      expect(find.text("Accept"), findsNothing);
      expect(find.text("Decline"), findsNothing);
    });

    testWidgets('Tapping Accept button triggers onAccept callback',
        (tester) async {
      bool acceptTapped = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          onAccept: () {
            acceptTapped = true;
          },
        ),
      );

      // Tap Accept button
      await tester.tap(find.text("Accept"));
      await tester.pump();

      expect(acceptTapped, isTrue);
    });

    testWidgets('Tapping Decline button triggers onDecline callback',
        (tester) async {
      bool declineTapped = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          onDecline: () {
            declineTapped = true;
          },
        ),
      );

      // Tap Decline button
      await tester.tap(find.text("Decline"));
      await tester.pump();

      expect(declineTapped, isTrue);
    });

    testWidgets('Shows CircularProgressIndicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          isLoading: true,
        ),
      );

      // Verify CircularProgressIndicator is rendered
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });

}
