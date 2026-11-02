import 'package:flutter/material.dart';
import 'package:easy2eat/core/enum/user_role.dart';
import 'package:easy2eat/core/theme/theme.dart';

// 1. Shared Navigation Bar (Aligned with multi-role navigation standard)
import 'package:easy2eat/shared/widgets/shared_navigation_bar.dart';

// 2. Vendor Core Feature Tabs
import 'package:easy2eat/features/vendor/presentation/HomeScreen/ui.dart';
import 'package:easy2eat/features/vendor/presentation/InventoryDetails/ui.dart';
import 'package:easy2eat/features/vendor/presentation/customer-conversation/ui.dart';

// 3. Shared Settings Page (Updated to match VendorSettingPage)
import 'package:easy2eat/features/vendor/presentation/setting/vendor-setting-page.dart';

class VendorMasterHomePage extends StatefulWidget {
  const VendorMasterHomePage({super.key});

  @override
  State<VendorMasterHomePage> createState() => _VendorMasterHomePageState();
}

class _VendorMasterHomePageState extends State<VendorMasterHomePage> {
  // Current active tab index for IndexedStack navigation
  int _currentIndex = 0;

  // 4 Core Tabs aligned strictly with RoleNavConfig for Vendor role
  late final List<Widget> _pages = const [
    // Tab 0: Vendor Home (Live Order Stream, Daily Revenue & Merchant Header)
    VendorHomePage(),

    // Tab 1: Stock & Inventory Management (Live Firestore Controls & Pricing)
    StockManagementPage(),

    // Tab 2: Vendor Conversations / Chat List (Live support & messaging gateway with customers)
    VendorConversationMainUI(),

    // Tab 3: Vendor Settings (Profile, Operations, Security & Logout)
    VendorSettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.scaffoldBackground,
      body: SafeArea(
        // IndexedStack preserves the state of each tab during switching
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