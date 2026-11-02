import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy2eat/features/customer/tracking/widgets/proximity_beacon_banner.dart';

void main() {
  group('Easy2Eat Customer Widget Tests - Proximity Components', () {
    testWidgets('TC-CW01: Beacon banner renders title, residence, and alert icon',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: CustomerProximityBeaconBanner(
                  residenceLabel: 'CHERAS TRADERS SQUARE • BLOCK C',
                  dropOffLandmark: 'Lobby Guardhouse',
                ),
              ),
            ),
          );

          // Verify header and landmark labels
          expect(find.text('100M PROXIMITY BEACON'), findsOneWidget);
          expect(find.text('CHERAS TRADERS SQUARE • BLOCK C'), findsOneWidget);
          expect(
            find.byWidgetPredicate(
                  (widget) =>
              widget is RichText &&
                  widget.text.toPlainText().contains('Lobby Guardhouse'),
            ),
            findsOneWidget,
          );

          // Verify bell icon presence
          expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
        });

    testWidgets('TC-CW02: Beacon banner layout handles long landmark without RenderFlex overflow',
            (WidgetTester tester) async {
          // Simulate compact 320px viewport
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: CustomerProximityBeaconBanner(
                  residenceLabel: 'VERY LONG RESIDENCE NAME • BLOCK C TOWER 2 HIGH FLOOR',
                  dropOffLandmark: 'Security Gate Counter Pillar 2 Drop Table',
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          // Confirms no RenderFlex overflow exception was thrown
          expect(tester.takeException(), isNull);

          addTearDown(tester.view.resetPhysicalSize);
        });
  });
}