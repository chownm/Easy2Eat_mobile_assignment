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
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: ThemesColors.darkCharcoal,
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: ThemesColors.darkCharcoal,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: ThemesColors.darkCharcoal,
                              size: 30,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Profile",
                              style: TextStyle(
                                color: ThemesColors.darkCharcoal,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          icon: const Icon(
            Icons.account_circle_rounded,
            size: 40,
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
