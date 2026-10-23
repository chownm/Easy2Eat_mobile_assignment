import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class EarningSummary extends StatefulWidget {
  const EarningSummary({super.key});

  @override
  State<EarningSummary> createState() => _EarningSummaryState();
}

class _EarningSummaryState extends State<EarningSummary> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display String "Earning Wallet"
          const Text(
            "Earning Wallet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ThemesColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 10),
          // Display Money
          const Text(
            "RM 100.00",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: ThemesColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 16),
          // Display trip count, Total time, and Total distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricItem("Trips", "10"),
              _buildMetricItem("Total Time", "2h 30m"),
              _buildMetricItem("Total Distance", "10km"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: ThemesColors.darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }
}
