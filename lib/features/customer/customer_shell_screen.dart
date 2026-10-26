import 'package:flutter/material.dart';
import 'package:easy2eat/core/enum/user_role.dart';
import 'package:easy2eat/features/customer/home/home_screen.dart';
import 'package:easy2eat/features/customer/cart_checkout/cart_checkout_screen.dart';
import 'package:easy2eat/shared/widgets/shared_navigation_bar.dart';

class CustomerShellScreen extends StatefulWidget{
  final int initialIndex;

  const CustomerShellScreen ({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<CustomerShellScreen> createState() => _CustomerShellScreenState();
}



class _CustomerShellScreenState extends State<CustomerShellScreen> {
  late int _currentIndex;

  // 4 Customer Root Page
  final List<Widget> _pages = const <Widget>[
    CustomerHomeScreen(),
    CustomerCartCheckoutScreen(),
    _PlaceholderTab(title: 'Live Tracking Screen (c_06)'), // Index 2: Track
    _PlaceholderTab(title: 'System Settings Screen (c_11)'), // Index 3: Settings
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
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



// Temporary placeholder
class _PlaceholderTab extends StatelessWidget {
  final String title;

  const _PlaceholderTab({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}