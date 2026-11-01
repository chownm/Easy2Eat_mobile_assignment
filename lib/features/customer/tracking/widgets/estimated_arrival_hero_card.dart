import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';

class CustomerEstimatedArrivalHeroCard extends StatelessWidget {
  final OrderTrackingStage stage;
  final String etaTimeDisplay;
  final int etaMinutesRemaining;
  final String etaBadgeLabel;
  final String stageDescription;

  const CustomerEstimatedArrivalHeroCard({
    super.key,
    required this.stage,
    required this.etaTimeDisplay,
    required this.etaMinutesRemaining,
    required this.etaBadgeLabel,
    required this.stageDescription,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDelivered = stage == OrderTrackingStage.delivered;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemesColors.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header Row: Label + Status Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'ESTIMATED ARRIVAL',
                style: TextStyle(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.55),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getBadgeBgColor(),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getBadgeBorderColor(),
                    width: 1,
                  ),
                ),
                child: Text(
                  etaBadgeLabel,
                  style: TextStyle(
                    color: _getBadgeTextColor(),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Digital Countdown Clock
          if (isDelivered)
            Row(
              children: <Widget>[
                const Icon(
                  Icons.check_circle_rounded,
                  color: ThemesColors.freshGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delivered at $etaTimeDisplay',
                  style: const TextStyle(
                    color: ThemesColors.freshGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  etaTimeDisplay,
                  style: const TextStyle(
                    color: ThemesColors.darkCharcoal,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '($etaMinutesRemaining mins)',
                  style: const TextStyle(
                    color: ThemesColors.brandOrange,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 4),

          // Contextual Plain-Language Stage Update
          Text(
            stageDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ThemesColors.darkCharcoal.withValues(alpha: 0.75),
              fontSize: 12,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeBgColor() {
    switch (stage) {
      case OrderTrackingStage.confirmed:
        return ThemesColors.darkCharcoal.withValues(alpha: 0.08);
      case OrderTrackingStage.preparing:
        return ThemesColors.promoYellow.withValues(alpha: 0.16);
      case OrderTrackingStage.readyForPickup:
        return Colors.amber.shade100;
      case OrderTrackingStage.onTheWay:
        return ThemesColors.brandOrange.withValues(alpha: 0.12);
      case OrderTrackingStage.delivered:
        return ThemesColors.freshGreen.withValues(alpha: 0.14);
    }
  }

  Color _getBadgeBorderColor() {
    switch (stage) {
      case OrderTrackingStage.confirmed:
        return ThemesColors.darkCharcoal.withValues(alpha: 0.18);
      case OrderTrackingStage.preparing:
        return ThemesColors.promoYellow.withValues(alpha: 0.45);
      case OrderTrackingStage.readyForPickup:
        return Colors.amber.shade400;
      case OrderTrackingStage.onTheWay:
        return ThemesColors.brandOrange.withValues(alpha: 0.35);
      case OrderTrackingStage.delivered:
        return ThemesColors.freshGreen.withValues(alpha: 0.4);
    }
  }

  Color _getBadgeTextColor() {
    switch (stage) {
      case OrderTrackingStage.confirmed:
        return ThemesColors.darkCharcoal.withValues(alpha: 0.85);
      case OrderTrackingStage.preparing:
        return ThemesColors.darkCharcoal;
      case OrderTrackingStage.readyForPickup:
        return Colors.brown.shade800;
      case OrderTrackingStage.onTheWay:
        return ThemesColors.brandOrange;
      case OrderTrackingStage.delivered:
        return ThemesColors.freshGreen;
    }
  }
}