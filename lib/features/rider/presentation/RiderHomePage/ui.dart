import 'package:easy2eat/features/rider/presentation/RiderHomePage/orderDetail.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:easy2eat/shared/widgets/shared_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import '../../../../core/enum/user_role.dart';
import 'statusSwitch.dart';

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const RiderAppBar(title: "Rider Delivery Page"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Switch at top
            const riderStatus(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Order Incoming",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemesColors.darkCharcoal,
                  ),
                ),
                IconButton(
                  onPressed: (){},
                  icon: const Icon(
                    Icons.refresh,
                    color: ThemesColors.darkCharcoal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Scrollable Order List
            const Expanded(child: orderDetail()),
          ],
        ),
      ),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.rider,
        onTap: (int index) {},
      ),
    );
  }
}
