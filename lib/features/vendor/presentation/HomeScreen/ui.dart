import 'package:flutter/material.dart';
import 'package:easy2eat/features/vendor/presentation/HomeScreen/merchantHeader.dart';
import 'package:easy2eat/features/vendor/presentation/HomeScreen/orderDetails&Status.dart';

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TopHeaderWidget(),
          SizedBox(height: 16),
          OrderDetailWidget(),
        ],
      ),
    );
  }
}