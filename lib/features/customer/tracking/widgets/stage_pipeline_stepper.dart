import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';

class CustomerStagePipelineStepper extends StatelessWidget {
  final OrderTrackingStage currentStage;
  final List<TrackingMilestoneModel> milestones;

  const CustomerStagePipelineStepper({
    super.key,
    required this.currentStage,
    required this.milestones,
  });

  @override
  Widget build(BuildContext context) {
    final int activeStep = currentStage.stepNumber;
    final TrackingMilestoneModel activeMilestone = milestones.firstWhere(
          (TrackingMilestoneModel m) => m.stageIndex == activeStep,
      orElse: () => milestones.first,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemesColors.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'ORDER STATUS PIPELINE',
                style: TextStyle(
                  color: ThemesColors.darkCharcoal,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                '4-Stage Model',
                style: TextStyle(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.5),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Horizontal Pipeline Nodes: 1 ── 2 ── 3 ── 4
          Row(
            children: <Widget>[
              _buildStepNode(1, 'Confirmed', activeStep),
              _buildConnectorLine(1, activeStep),
              _buildStepNode(2, 'Preparing', activeStep),
              _buildConnectorLine(2, activeStep),
              _buildStepNode(3, 'On the Way', activeStep),
              _buildConnectorLine(3, activeStep),
              _buildStepNode(4, 'Delivered', activeStep),
            ],
          ),

          const SizedBox(height: 10),

          // Single Active Description Box (Drastically reduces height!)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF9F2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ThemesColors.promoYellow.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'STAGE $activeStep ACTIVE',
                      style: const TextStyle(
                        color: ThemesColors.brandOrange,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    if (activeMilestone.completedTimestamp != null)
                      Text(
                        activeMilestone.completedTimestamp!,
                        style: TextStyle(
                          color: ThemesColors.darkCharcoal.withValues(
                            alpha: 0.55,
                          ),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  activeMilestone.subtitle,
                  style: TextStyle(
                    color: ThemesColors.darkCharcoal.withValues(alpha: 0.85),
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNode(int stepNumber, String label, int activeStep) {
    final bool isCompleted = stepNumber < activeStep;
    final bool isActive = stepNumber == activeStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? ThemesColors.freshGreen
                : (isActive
                ? ThemesColors.promoYellow
                : ThemesColors.darkCharcoal.withValues(alpha: 0.08)),
            boxShadow: isActive
                ? <BoxShadow>[
              BoxShadow(
                color: ThemesColors.promoYellow.withValues(alpha: 0.35),
                blurRadius: 4,
                spreadRadius: 2,
              ),
            ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
              Icons.check_rounded,
              color: ThemesColors.appSurface,
              size: 14,
            )
                : Text(
              '$stepNumber',
              style: TextStyle(
                color: isActive
                    ? ThemesColors.darkCharcoal
                    : ThemesColors.darkCharcoal.withValues(alpha: 0.4),
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            color: (isCompleted || isActive)
                ? ThemesColors.darkCharcoal
                : ThemesColors.darkCharcoal.withValues(alpha: 0.4),
            fontSize: 9.5,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectorLine(int stepNumber, int activeStep) {
    final bool isCompleted = stepNumber < activeStep;

    return Expanded(
      child: Container(
        height: 2.5,
        margin: const EdgeInsets.only(bottom: 14, left: 2, right: 2),
        color: isCompleted
            ? ThemesColors.freshGreen
            : ThemesColors.darkCharcoal.withValues(alpha: 0.12),
      ),
    );
  }
}