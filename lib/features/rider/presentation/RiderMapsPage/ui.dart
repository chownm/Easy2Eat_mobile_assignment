import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:flutter/material.dart';

import '../../../../core/enum/user_role.dart';
import '../../../../shared/widgets/shared_navigation_bar.dart';

class RiderMapsPage extends StatefulWidget {
  const RiderMapsPage({super.key});

  @override
  State<RiderMapsPage> createState() => _RiderMapsPageState();
}

class _RiderMapsPageState extends State<RiderMapsPage> {
  int get _currentIndex => 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const RiderAppBar(title: "Rider Maps Page"),
      body: const Center(
        child: Text("Rider Maps Page"),
      ),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.rider,
        onTap: (int index) {},
      ),
    );
  }
}
