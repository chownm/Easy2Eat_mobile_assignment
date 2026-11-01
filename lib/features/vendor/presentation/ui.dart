import 'package:flutter/material.dart';
import 'package:easy2eat/core/enum/user_role.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/shared/widgets/shared_navigation_bar.dart';
import 'package:easy2eat/features/vendor/presentation/HomeScreen/ui.dart';
import 'package:easy2eat/features/vendor/presentation/InventoryDetails/ui.dart';

class VendorMasterHomePage extends StatefulWidget {
  const VendorMasterHomePage({super.key});

  @override
  State<VendorMasterHomePage> createState() => _VendorMasterHomePageState();
}

class _VendorMasterHomePageState extends State<VendorMasterHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    // 0: Vendor Home (Live Order Stream & Merchant Header)
    VendorHomePage(),

    // 1: Stock & Inventory Management
    StockManagementPage(),

    // 2: Track & Monitoring
    Center(
      child: Text(
        'Track & Monitoring Page',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ThemesColors.textPrimary,
        ),
      ),
    ),

    // 3: Vendor Settings
    Center(
      child: Text(
        'Vendor Settings Page',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ThemesColors.textPrimary,
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.scaffoldBackground,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
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