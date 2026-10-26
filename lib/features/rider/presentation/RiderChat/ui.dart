import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/chatSectionCard.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/chatTileItem.dart';
import 'package:easy2eat/features/rider/presentation/RiderChat/searchMessages.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../core/constants/active_delivery.dart';
import '../../../../core/enum/user_role.dart';
import '../../../../shared/widgets/shared_navigation_bar.dart';

class RiderChat extends StatelessWidget {
  const RiderChat({super.key});

  int get _currentIndex => 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: RiderAppBar(title: 'riderChatPage'.tr()),
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
                    title: 'today'.tr(),
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
                          Navigator.pushNamed(
                            context,
                            AppRoutes.chatWindow,
                            arguments: chat.title,
                          );
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
