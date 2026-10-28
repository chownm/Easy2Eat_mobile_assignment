import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/user_session.dart';
import '../../../../core/theme/theme.dart';

class EarningSummary extends StatelessWidget {
  const EarningSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = UserSession.currentUid ?? 'guest_rider';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recent_trips')
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];

        int tripCount = docs.length;
        double totalEarnings = 0.0;

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final earningStr = data['earning']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0';
          totalEarnings += double.tryParse(earningStr) ?? 0.0;
        }

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
              Text(
                "RM ${totalEarnings.toStringAsFixed(2)}",
                style: const TextStyle(
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
                  _buildMetricItem("Trips", "$tripCount"),
                  _buildMetricItem("Total Time", "${tripCount * 15}m"),
                  _buildMetricItem("Total Distance", "${tripCount * 3}km"),
                ],
              ),
            ],
          ),
        );
      },
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
