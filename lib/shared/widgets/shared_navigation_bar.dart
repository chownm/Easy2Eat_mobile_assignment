import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/core/enum/user_role.dart';
import 'package:easy2eat/core/navigation/role_nav_config.dart';

// Navigation Bar
class SharedNavigationBar extends StatelessWidget {
  final int currentIndex;
  final UserRole role;
  final ValueChanged<int> onTap;

  const SharedNavigationBar ({
    super.key,
    required this.currentIndex,
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<NavigationTabItem> tabItems = RoleNavConfig.getItemForRole(role);
    return Container(
      decoration: BoxDecoration(
        color: ThemesColors.appSurface,
        border: Border(
          top: BorderSide(
            color: ThemesColors.darkCharcoal.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex.clamp(0, tabItems.length - 1),
        type: BottomNavigationBarType.fixed,
        backgroundColor: ThemesColors.appSurface,
        selectedItemColor: ThemesColors.brandOrange,
        unselectedItemColor: ThemesColors.darkCharcoal.withValues(alpha: 0.4),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        onTap: onTap,
        items: tabItems.map((tab){
          return BottomNavigationBarItem(
              label: tab.label,
              icon: Icon(tab.icon),
              activeIcon: Icon(tab.activeIcon),
          );
        }).toList(),
      ),
    );
  }
}