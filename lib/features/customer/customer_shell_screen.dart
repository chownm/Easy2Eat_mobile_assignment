import 'package:easy2eat/features/customer/settings/setting_screen.dart';
import 'package:easy2eat/features/customer/tracking/tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/enum/user_role.dart';
import 'package:easy2eat/features/customer/home/home_screen.dart';
import 'package:easy2eat/features/customer/cart_checkout/cart_checkout_screen.dart';
import 'package:easy2eat/shared/widgets/shared_navigation_bar.dart';


class CustomerShellScreen extends StatefulWidget{
  final int initialIndex;
  final String? activeOrderId;

  const CustomerShellScreen ({
    super.key,
    this.initialIndex = 0,
    this.activeOrderId,
  });

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}

class _CustomerShellScreenState extends State<CustomerShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // 2. Moved pages inside build() to access widget.activeOrderId dynamically
    final List<Widget> pages = <Widget>[
      const CustomerHomeScreen(),
      const CustomerCartCheckoutScreen(),
      CustomerTrackingScreen(
        // Uses the real order ID if checked out, else falls back to mock for normal tab tapping
        orderId: widget.activeOrderId ?? 'E2E-89241',
      ),
      const CustomerSettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.customer,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
