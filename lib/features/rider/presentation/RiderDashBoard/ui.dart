import 'package:easy2eat/features/rider/presentation/RiderDashBoard/DeliveryHistory.dart';
import 'package:easy2eat/features/rider/presentation/RiderDashBoard/EarningSummary.dart';
import 'package:easy2eat/features/rider/presentation/RiderDashBoard/RefreshButton.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';

class RiderDashBoard extends StatefulWidget {
  const RiderDashBoard({super.key});

  @override
  State<RiderDashBoard> createState() => _RiderDashBoardState();
}

class _RiderDashBoardState extends State<RiderDashBoard> {
  void _refreshDashboard() {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dashboard refreshed from Firestore!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const RiderSubAppBar(title: "Rider Dashboard"),
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
                  onPressed: _refreshDashboard,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Earning Summary Card (Calculates total earnings dynamically)
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

            // Dynamic Delivery History List fetched from Firestore
            const Expanded(
              child: Scrollbar(
                child: DeliveryHistoryList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
