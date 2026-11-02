import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/vendor/presentation/customer-conversation/message-widget.dart';

/// 1. Vendor Chat Session List Page (Mounted on the Master Home Page chat tab)
class VendorChatWidget extends StatelessWidget {
  const VendorChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ThemesColors.appSurface,
        elevation: 0,
        title: const Text(
          'Customer Conversations',
          style: TextStyle(
            color: ThemesColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      // Real-time listener for the orders collection
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No active customer chats found.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              // Extract order ID and customer name (with fallback placeholders)
              final String orderId = data['orderID'] ?? doc.id;
              final String customerName = data['customerName'] ?? 'Valued Customer';
              final String status = data['preparationStatus'] ?? data['status'] ?? 'active';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    child: Text(
                      customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: ThemesColors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Order: $orderId • Status: $status',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    // Navigate to specific chat room with orderId and customerName
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VendorChatPage(
                          orderId: orderId,
                          customerName: customerName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}