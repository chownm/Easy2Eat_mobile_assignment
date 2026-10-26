import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/cart_item_model.dart';

// Component 1: Drop-Off Precision and Shift Timing Card
class CustomerDeliveryPinCard extends StatelessWidget {
  final DropOffPinModel pin;
  final DeliveryTimingMode selectedTimingMode;
  final ValueChanged<DeliveryTimingMode> ? onTimingModeChanged;
  final VoidCallback? onEditPinTap;

  const CustomerDeliveryPinCard ({
    super.key,
    required this.pin,
    this.selectedTimingMode = DeliveryTimingMode.immediateDirect,
    this.onTimingModeChanged,
    this.onEditPinTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isImmediate =
        selectedTimingMode == DeliveryTimingMode.immediateDirect;

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
          // Row 1: Section Label + <1km validation badge
          Row(
            children: <Widget>[
              const Icon(
                Icons.pin_drop_rounded,
                color: ThemesColors.brandOrange,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Drop-off Precision Hub',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemesColors.darkCharcoal,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (pin.isDirectUnstackedEligible)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ThemesColors.freshGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ThemesColors.freshGreen.withValues(alpha: 0.35),
                    )
                  ),
                  child: Text(
                    '${pin.distanceKm.toStringAsFixed(1)} km • Unstacked',
                    style: const TextStyle(
                      color: ThemesColors.freshGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Hub Zone title and micro-pin landmark + Edit Sub-pin button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemesColors.darkCharcoal.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ThemesColors.darkCharcoal.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        pin.hubZoneTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ThemesColors.darkCharcoal,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sub-Pin: ${pin.microPinLandmark}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ThemesColors.darkCharcoal.withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onEditPinTap ?? () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ThemesColors.appSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ThemesColors.darkCharcoal.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Text(
                      'Sub-Pin',
                      style: TextStyle(
                        color: ThemesColors.darkCharcoal,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Row 3: Attached Photo Note Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: ThemesColors.appSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ThemesColors.darkCharcoal.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.camera_alt_outlined,
                  color: ThemesColors.darkCharcoal,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pin.referencePhotoNote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ThemesColors.darkCharcoal.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle_rounded,
                  color: ThemesColors.freshGreen,
                  size: 16,
                )
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Row 4: Dispatch Timing Toggle
          Row(
            children: <Widget>[
              Expanded(
                child: _TimingModeOptionButton(
                  icon: Icons.bolt_rounded,
                  label: 'Direct (<1km)',
                  isSelected: isImmediate,
                  onTap: () => onTimingModeChanged?.call(
                    DeliveryTimingMode.immediateDirect,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TimingModeOptionButton(
                  icon: Icons.schedule_rounded,
                  label: 'Shift Pre-Order',
                  isSelected: !isImmediate,
                  onTap: () => onTimingModeChanged?.call(
                    DeliveryTimingMode.scheduledShift,
                  ),
                ),
              ),
            ],
          ),

          // Shift Window Banner
          if(!isImmediate) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: ThemesColors.promoYellow.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Target Window: ${pin.scheduledShiftWindow}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: ThemesColors.darkCharcoal,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}



// Helper button for switching between Immediate Direct and Shift Pre-order
class _TimingModeOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimingModeOptionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? ThemesColors.darkCharcoal : ThemesColors.appSurface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? ThemesColors.darkCharcoal
                  : ThemesColors.darkCharcoal.withValues(alpha: 0.22),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 15,
                color: isSelected
                    ? ThemesColors.promoYellow
                    : ThemesColors.darkCharcoal,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? ThemesColors.appSurface
                        : ThemesColors.darkCharcoal,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}