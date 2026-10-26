import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/features/rider/presentation/RiderMapsPage/Map.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/active_delivery.dart';
import '../../../../core/enum/user_role.dart';
import '../../../../shared/widgets/shared_navigation_bar.dart';

class RiderMapsPage extends StatelessWidget {
  final String? deliveryNumber;

  const RiderMapsPage({
    super.key,
    this.deliveryNumber,
  });

  int get _currentIndex => 1;

  @override
  Widget build(BuildContext context) {
    final String activeNum = deliveryNumber ?? ActiveDeliveryState.currentDeliveryNumber;

    return Scaffold(
      appBar: RiderAppBar(title: 'riderMapsPage'.tr()),
      body: GeoapifyMapWidget(deliveryNumber: activeNum, name: "Chow Booh Hwa"),
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
