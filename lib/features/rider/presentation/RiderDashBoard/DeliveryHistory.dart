import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class DeliveryHistory extends StatelessWidget {
  final String orderCode;
  final String time;
  final String storeName;
  final String dropoffLocation;
  final String earning;
  final VoidCallback? onTap;

  const DeliveryHistory({
    super.key,
    required this.orderCode,
    required this.time,
    required this.storeName,
    required this.dropoffLocation,
    required this.earning,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: ThemesColors.darkCharcoal,
            size: 22,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Line 1: Order Code & Time
            Row(
              children: [
                Text(
                  orderCode,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ThemesColors.darkCharcoal,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Line 2: Store Name -> Dropoff & Earning Amount
            Row(
              children: [
                Expanded(
                  child: Text(
                    "$storeName → $dropoffLocation",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  earning,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ThemesColors.darkCharcoal,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }
}

/// Dynamic List Builder for Delivery History
class DeliveryHistoryList extends StatelessWidget {
  final int itemCount;

  const DeliveryHistoryList({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return DeliveryHistory(
          orderCode: "#E2E-${8842 - index}",
          time: "12:44 PM",
          storeName: "Kedai Kopi Makcik",
          dropoffLocation: "Subang Jaya",
          earning: "RM ${(9.50 + index).toStringAsFixed(2)}",
          onTap: () {},
        );
      },
    );
  }
}
