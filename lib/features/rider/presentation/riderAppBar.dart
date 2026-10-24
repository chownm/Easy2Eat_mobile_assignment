import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';

class RiderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const RiderAppBar({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(title),
      toolbarTextStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: ThemesColors.darkCharcoal,
        letterSpacing: 0.5,
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') {
              Navigator.pushNamed(context, AppRoutes.settings);
            } else if (value == 'dashboard') {
              Navigator.pushNamed(context, AppRoutes.riderDashboard);
            } else if (value == 'logout') {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: ThemesColors.darkCharcoal,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Profile & Settings",
                    style: TextStyle(
                      color: ThemesColors.darkCharcoal,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'dashboard',
              child: Row(
                children: [
                  Icon(
                    Icons.dashboard_outlined,
                    color: ThemesColors.darkCharcoal,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      color: ThemesColors.darkCharcoal,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 22,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Logout",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          icon: const Icon(
            Icons.account_circle_rounded,
            size: 38,
            color: ThemesColors.darkCharcoal,
          ),
        ),
      ],
      backgroundColor: ThemesColors.brandOrange,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }
}

// Alias for backwards compatibility
typedef riderAppBar = RiderAppBar;
