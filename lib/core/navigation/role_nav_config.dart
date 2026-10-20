import 'package:flutter/material.dart';
import 'package:easy2eat/core/enum/user_role.dart';

class RoleNavConfig {
  static List<NavigationTabItem> getItemForRole(UserRole role) {
    switch(role) {
      case UserRole.customer:
        return const [
          NavigationTabItem(
            label: 'Home',
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront_rounded,
          ),
          NavigationTabItem(
            label: 'Cart',
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
          ),
          NavigationTabItem(
            label: 'Track',
            icon: Icons.radar_outlined,
            activeIcon: Icons.radar_rounded,
          ),
          NavigationTabItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
          ),
        ];

      case UserRole.vendor:
        return const [
          NavigationTabItem(
            label: 'Home',
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront_rounded,
          ),
          NavigationTabItem(
            label: 'Cart',
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
          ),
          NavigationTabItem(
            label: 'Track',
            icon: Icons.radar_outlined,
            activeIcon: Icons.radar_rounded,
          ),
          NavigationTabItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
          ),
        ];

      case UserRole.rider:
        return const [
          NavigationTabItem(
            label: 'Home',
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront_rounded,
          ),
          NavigationTabItem(
            label: 'Cart',
            icon: Icons.shopping_bag_outlined,
            activeIcon: Icons.shopping_bag_rounded,
          ),
          NavigationTabItem(
            label: 'Track',
            icon: Icons.radar_outlined,
            activeIcon: Icons.radar_rounded,
          ),
          NavigationTabItem(
            label: 'Settings',
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
          ),
        ];
    }
  }
}