import 'package:flutter/material.dart';

enum UserRole {
  customer,
  vendor,
  rider,
}

class NavigationTabItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavigationTabItem ({
   required this.label,
   required this.icon,
   required this.activeIcon,
  });
}