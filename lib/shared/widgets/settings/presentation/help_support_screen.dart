import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  List<Map<String, String>> _getFaqsForRole(String role) {
    final cleanRole = role.toLowerCase();

    if (cleanRole == 'customer') {
      return [
        {
          "title": "How do I track my active food order in real-time?",
          "content":
              "Go to the Order Tracking page to see real-time updates on your order stage, estimated arrival time, rider details, and live beacon updates."
        },
        {
          "title": "How can I chat with my delivery rider?",
          "content":
              "On the Order Tracking page, tap the chat icon next to your rider's profile to open a live chat window and send messages or delivery instructions."
        },
        {
          "title": "What payment methods are supported?",
          "content":
              "We support major Credit/Debit Cards, Online Banking (FPX), and E-wallets for fast and secure checkout."
        },
        {
          "title": "How do I change my delivery address?",
          "content":
              "You can select or update your delivery address pin on the Checkout screen before placing an order."
        },
      ];
    } else if (cleanRole == 'vendor') {
      return [
        {
          "title": "How do I accept and manage incoming restaurant orders?",
          "content":
              "Go to the Merchant Orders screen to view incoming customer orders, accept orders, and update kitchen preparation status."
        },
        {
          "title": "How do I generate and present the Vendor QR code?",
          "content":
              "Go to the QR Screen on your merchant portal to display your store's unique QR code for riders to scan upon pickup."
        },
        {
          "title": "How do I update my restaurant menu items and inventory?",
          "content":
              "Navigate to Item Page under Merchant Store to add new food items, update prices, or toggle item availability."
        },
        {
          "title": "How do I view daily sales earnings?",
          "content":
              "Tap the Chart Page in your Merchant Store dashboard to view daily, weekly, and monthly sales analytics."
        },
      ];
    } else {
      // Default to Rider FAQs
      return [
        {
          "title": "How do I accept and complete a delivery?",
          "content":
              "Go to the Delivery Page, tap 'Accept' on an incoming order. Next, tap 'View Route' to see directions on the Map, scan the Vendor QR code, and tap 'Arrived' once delivered to the customer."
        },
        {
          "title": "How is my 10% rider earning calculated?",
          "content":
              "Rider earnings are automatically calculated as 10% of the total food order price. Earnings update in your Earning Wallet on the Dashboard immediately upon completing a delivery."
        },
        {
          "title": "What if the customer is not answering the chat?",
          "content":
              "Tap 'Chat Customer' from the Maps or Chat page to send an automated delivery status message. You can also leave the order safely at the designated drop table and tap 'Arrived'."
        },
        {
          "title": "How do I update my profile or password?",
          "content":
              "You can update your personal details on the 'Profile details' page or change your password under 'Password setting' inside Settings."
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final String role = (UserSession.role != null && UserSession.role!.isNotEmpty)
        ? UserSession.role!
        : 'customer';
    final faqs = _getFaqsForRole(role);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const RiderSubAppBar(title: "Help & Support"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Frequently Asked Questions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ThemesColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Find quick answers for ${role.toUpperCase()} account below.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Render Role-Based FAQs
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return _buildFaqTile(
                    title: faq["title"]!,
                    content: faq["content"]!,
                  );
                },
              ),
              const SizedBox(height: 28),

              // Need More Help Header
              const Text(
                "Need Further Assistance?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ThemesColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 12),

              // Contact Support Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: ThemesColors.brandOrange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        color: ThemesColors.brandOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "24/7 Customer Support",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: ThemesColors.darkCharcoal,
                            ),
                          ),
                          Text(
                            "Email: support@easy2eat.com",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemesColors.darkCharcoal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Support team notified! An agent will respond shortly."),
                            backgroundColor: ThemesColors.success,
                          ),
                        );
                      },
                      child: const Text("Contact"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqTile({required String title, required String content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: ThemesColors.brandOrange,
        collapsedIconColor: ThemesColors.darkCharcoal,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: ThemesColors.darkCharcoal,
          ),
        ),
        children: [
          Text(
            content,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
