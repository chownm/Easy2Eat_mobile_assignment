import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

class SettingsTileItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBgColor;
  final String title;
  final String? subtitle; // Optional: Leave null for simple style (Image 4)
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTileItem({
    super.key,
    required this.icon,
    this.iconColor = const Color(0xFF1C1A19),
    this.iconBgColor,
    required this.title,
    this.subtitle, // Leave null for title-only layout
    this.trailing = const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconBgColor ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ThemesColors.darkCharcoal,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle!,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      )
          : null,
      trailing: trailing,
    );
  }
}