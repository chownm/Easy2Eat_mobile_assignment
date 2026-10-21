import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:flutter/material.dart';

import '../../../../core/enum/user_role.dart';
import '../../../../shared/widgets/shared_navigation_bar.dart';

class RiderSettingPage extends StatelessWidget {
  const RiderSettingPage({super.key});

  int get _currentIndex => 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RiderAppBar(title: "Setting Page"),
      body: const Center(
        child: Text("Setting Page"),
      ),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.rider,
        onTap: (int index) {},
      ),
    );
  }
}
