import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? avatarPath;
  final double height;

  const ChatAppBar({
    super.key,
    required this.title,
    this.subtitle = "Online",
    this.avatarPath,
    this.height = 70.0, // Custom App Bar Height
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemesColors.brandOrange,
      elevation: 1.0,
      titleSpacing: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),

      // Back Button
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: ThemesColors.darkCharcoal),
        onPressed: () {
          Navigator.maybePop(context);
        },
        iconSize: 26,
      ),

      // Title: Avatar + User Name + Online Status
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            backgroundImage: avatarPath != null ? AssetImage(avatarPath!) : null,
            child: avatarPath == null
                ? const Icon(Icons.person, color: ThemesColors.darkCharcoal, size: 22)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2, // Expand up to 2 lines for long names before ...
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ThemesColors.darkCharcoal,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: ThemesColors.darkCharcoal.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),

      // Action Buttons (Call & Info)
      actions: [
        IconButton(
          icon: const Icon(Icons.phone_outlined, color: ThemesColors.darkCharcoal),
          onPressed: () {},
          iconSize: 22,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
        IconButton(
          icon: const Icon(Icons.info_outline, color: ThemesColors.darkCharcoal),
          onPressed: () {},
          iconSize: 22,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}
