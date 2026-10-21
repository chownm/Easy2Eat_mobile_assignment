import 'package:easy2eat/features/rider/presentation/RiderChat/chatSectionCard.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/chatTitleItem.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/searchMessages.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:flutter/material.dart';

import '../../../../core/enum/user_role.dart';
import '../../../../shared/widgets/shared_navigation_bar.dart';

class RiderChat extends StatelessWidget {
  const RiderChat({super.key});

  int get _currentIndex => 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const RiderAppBar(title: "Rider Chat Page"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            const SearchMessages(),
            const SizedBox(height: 16),

            // Scrollable Chat Section Card
            Expanded(
              child: ChatSectionCard(
                itemCount: 3,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return ChatTileItem(
                      initials: "AS",
                      hasStatusDot: true,
                      title: "Alex Sterling • Order #0001",
                      subtitle: "Saya dah sampai depan guard h...",
                      time: "12:43 PM",
                      unreadCount: 1,
                      onTap: () {},
                    );
                  } else if (index == 1) {
                    return ChatTileItem(
                      icon: Icons.storefront_outlined,
                      title: "Kedai Kopi Makcik",
                      subtitle: "Order is almost packed, ready in...",
                      time: "12:35 PM",
                      onTap: () {},
                    );
                  } else {
                    return ChatTileItem(
                      icon: Icons.support_agent,
                      title: "Rider Dispatch Support ✔",
                      subtitle: "Peak rain incentive +RM2.50/tri...",
                      time: "10:15 AM",
                      onTap: () {},
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.rider,
        onTap: (int index) {},
      ),
    );
  }
}
