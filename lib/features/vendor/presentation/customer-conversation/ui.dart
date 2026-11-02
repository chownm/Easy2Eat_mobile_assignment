import 'package:flutter/material.dart';
import 'package:easy2eat/features/vendor/presentation/customer-conversation/message-list.dart';
import 'package:easy2eat/features/vendor/presentation/customer-conversation/message-widget.dart';

/// Vendor Conversation Module Entrypoint Widget
class VendorConversationMainUI extends StatelessWidget {
  const VendorConversationMainUI({super.key});

  @override
  Widget build(BuildContext context) {
    // Default view displaying the vendor chat session list
    return const VendorChatWidget();
  }

  /// Static helper method to directly open a specific chat room from other pages
  static void openChatRoom({
    required BuildContext context,
    required String orderId,
    required String customerName,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VendorChatPage(
          orderId: orderId,
          customerName: customerName,
        ),
      ),
    );
  }
}