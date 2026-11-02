import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';
import 'package:easy2eat/features/vendor/presentation/HomeScreen/merchantHeader.dart';
import 'package:easy2eat/features/vendor/presentation/HomeScreen/orderDetails&Status.dart';
import 'package:easy2eat/features/vendor/presentation/HomeScreen/dailyRevenue.dart'; // Adjust import path according to your project structure

class VendorHomePage extends StatefulWidget {
  const VendorHomePage({super.key});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  @override
  Widget build(BuildContext context) {
    // Real-time listener for the orders collection in Firestore
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        // 1. Safely parse Firestore documents into a list of OrderModel objects using fromJson
        List<OrderModel> liveOrders = [];
        if (snapshot.hasData) {
          liveOrders = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Ensure document ID is mapped as orderID if missing in document body
            data['orderID'] ??= doc.id;

            return OrderModel.fromJson(data);
          }).toList();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Merchant header / store info widget
              const TopHeaderWidget(),
              const SizedBox(height: 16),

              // 2. Dynamic daily revenue and order metrics card (powered by liveOrders)
              DailyRevenueWidget(orders: liveOrders),
              const SizedBox(height: 16),

              // 3. Order list and kitchen preparation status workflow component
              const OrderDetailWidget(),
            ],
          ),
        );
      },
    );
  }
}