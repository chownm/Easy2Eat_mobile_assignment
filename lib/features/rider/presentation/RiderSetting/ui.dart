import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:flutter/material.dart';

import '../../../../core/enum/user_role.dart';
import '../../../../core/routing/RiderRouting.dart';
import '../../../../shared/widgets/settings/presentation/ui.dart';
import '../../../../shared/widgets/shared_navigation_bar.dart';

class RiderSettingPage extends StatelessWidget {
  const RiderSettingPage({super.key});

  int get _currentIndex => 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const RiderAppBar(title: "Rider Settings Page"),
      body: const SettingsPage(),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.rider,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.riderHome);
          }
          if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRoutes.riderMaps);
          }
          if (index == 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.riderChat);
          }
        },
      ),
    );
  }
}
