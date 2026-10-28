import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/chatSectionCard.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/chatTileItem.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/searchMessages.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/shared/widgets/ChatWindow/ui.dart';

import '../../../../core/constants/active_delivery.dart';
import '../../../../core/enum/user_role.dart';
import '../../../../shared/widgets/shared_navigation_bar.dart';

class RiderChat extends StatefulWidget {
  const RiderChat({super.key});

  @override
  State<RiderChat> createState() => _RiderChatState();
}

class _RiderChatState extends State<RiderChat> {
  int get _currentIndex => 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const RiderAppBar(title: "Rider Chat Page"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            // Search Bar
            const SearchMessages(),
            const SizedBox(height: 16),

            ChatListState.activeChats.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No active chats yet",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tap 'Chat Vendor' or 'Chat Customer' from the Maps page to start chatting.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Scrollbar(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        ChatSectionCard(
                          title: "TODAY",
                          children: ChatListState.activeChats.map((chat) {
                            return ChatTileItem(
                              icon: chat.icon,
                              initials: chat.icon == null ? chat.initials : null,
                              hasStatusDot: true,
                              title: chat.title,
                              subtitle: chat.subtitle,
                              time: chat.time,
                              unreadCount: 1,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ChatWindow(
                                      title: 'Customer (Gate Pillar 2)',
                                      subtitle: 'Order #E2E-89241',
                                      chatRoomId: 'order_E2E-89241', // Exact same room as Customer!
                                      isCustomerView: false,         // Sets role to Rider!
                                    ),
                                  ),
                                ).then((_) {
                                  setState(() {});
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.rider,
        onTap: (int index) {
          if (index == 0) Navigator.pushReplacementNamed(context, AppRoutes.riderHome);
          if (index == 1) Navigator.pushReplacementNamed(context, AppRoutes.riderMaps);
          if (index == 3) Navigator.pushReplacementNamed(context, AppRoutes.settings);
        },
      ),
    );
  }
}
