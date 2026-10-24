import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/features/rider/presentation/RiderMapsPage/Map.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:flutter/material.dart';

import '../../../../core/enum/user_role.dart';
import '../../../../shared/widgets/shared_navigation_bar.dart';

class RiderMapsPage extends StatelessWidget {
  const RiderMapsPage({super.key});

  int get _currentIndex => 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RiderAppBar(title: "Rider Maps Page"),
      body: GeoapifyMapWidget(deliveryNumber: "Delivery Number 1234", name: "Chow Booh Hwa"),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.rider,
        onTap: (int index) {
          if (index == 0) Navigator.pushReplacementNamed(context, AppRoutes.riderHome);
          if (index == 2) Navigator.pushReplacementNamed(context, AppRoutes.riderChat);
          if (index == 3) Navigator.pushReplacementNamed(context, AppRoutes.settings);
        },
      ),
    );
  }
}
