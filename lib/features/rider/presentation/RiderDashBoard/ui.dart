import 'package:easy2eat/features/rider/presentation/RiderDashBoard/DeliveryHistory.dart';
import 'package:easy2eat/features/rider/presentation/RiderDashBoard/EarningSummary.dart';
import 'package:easy2eat/features/rider/presentation/RiderDashBoard/RefreshButton.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';

class RiderDashBoard extends StatelessWidget {
  const RiderDashBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: ThemesColors.brandOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ThemesColors.darkCharcoal),
          onPressed: () {
            Navigator.maybePop(context);
          },
          iconSize: 28,
        ),
        title: const Text(
          'Rider Dashboard',
          style: TextStyle(
            color: ThemesColors.darkCharcoal,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row with Title and Refresh Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Earnings Overview",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemesColors.darkCharcoal,
                  ),
                ),
                RefreshButton(
                  onPressed: () {
                    // Trigger refresh
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Earning Summary Card
            const EarningSummary(),
            const SizedBox(height: 16),

            // Delivery History Section
            const Text(
              "Recent Trip",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemesColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: 12),

            // Dynamic Delivery History List
            const Expanded(
              child: Scrollbar(
                child: DeliveryHistoryList(
                  itemCount: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
