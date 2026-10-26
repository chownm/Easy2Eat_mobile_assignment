import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/enum/user_role.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/shared/widgets/shared_navigation_bar.dart';
//import 'package:easy2eat/features/vendor/presentation/HomeScreen/ui.dart';
import 'package:easy2eat/features/vendor/presentation/InventoryDetails/ui.dart';


class VendorMasterHomePage extends ConsumerStatefulWidget {
  const VendorMasterHomePage({super.key});

  @override
  ConsumerState<VendorMasterHomePage> createState() => _VendorMasterHomePageState();
}

class _VendorMasterHomePageState extends ConsumerState<VendorMasterHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    //VendorHomePage(),
    StockManagementPage(),

    Center(
      child: Text(
        'Track & Monitoring Page',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemesColors.textPrimary),
      ),
    ),

    Center(
      child: Text(
        'Vendor Settings Page',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: ThemesColors.textPrimary),
      ),
    ),
  ];

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.scaffoldBackground,

      body: SafeArea(
          child: _pages[_currentIndex],
      ),

      bottomNavigationBar: SharedNavigationBar(
          currentIndex: _currentIndex,
          role: UserRole.vendor,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
      ),
    );
  }

}