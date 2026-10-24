import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/chatSectionCard.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/chatTileItem.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          children: [
            // Search Bar
            const SearchMessages(),
            const SizedBox(height: 16),

            Scrollbar(
              child: ListView(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  ChatSectionCard(
                    title: "TODAY",
                    children: [
                      ChatTileItem(
                        initials: "AS",
                        hasStatusDot: true,
                        title: "Alex Sterling • Order #0001",
                        subtitle: "Saya dah sampai depan guard h...",
                        time: "12:43 PM",
                        unreadCount: 1,
                        onTap: () {
                          Navigator.pushNamed(context, "/chatWindow");
                        },
                      ),
                    ],
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
