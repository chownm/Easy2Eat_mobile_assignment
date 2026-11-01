import 'package:flutter/material.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';

class DailyRevenueWidget extends StatelessWidget {
  final List<OrderModel> orders; // Dynamic order stream from Firestore

  const DailyRevenueWidget({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    // 1. Dynamically calculate total orders count
    int totalOrders = orders.length;

    // 2. Dynamically calculate total daily revenue by summing up all order totals
    double totalRevenue = orders.fold(0.0, (sum, order) => sum + order.totalPrice);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black, // Premium sleek black card design
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Today's Total Orders metric
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TODAY'S ORDERS",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$totalOrders',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.arrow_upward, color: Colors.greenAccent, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '+14% vs yesterday',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          // Right side: Daily Revenue capsule card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'DAILY REVENUE',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RM ${totalRevenue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}