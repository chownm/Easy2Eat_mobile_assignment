import 'package:easy2eat/features/vendor/presentation/HomeScreen/dailyRevenue.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/features/vendor/presentation/HomeScreen/merchantHeader.dart';
import 'package:easy2eat/features/vendor/presentation/HomeScreen/orderDetails&Status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VendorHomePage extends StatelessWidget {
  const VendorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopHeaderWidget(),
          SizedBox(height: 16),
          DailyRevenueWidget(),
          SizedBox(height: 20),
          OrderDetailWidget(),
        ],
      ),
    );
  }
}
