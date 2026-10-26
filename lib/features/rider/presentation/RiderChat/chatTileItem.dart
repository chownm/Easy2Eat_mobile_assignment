import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class ChatTileItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? time;
  final IconData? icon;
  final String? imagePath;
  final String? initials;
  final bool hasStatusDot;
  final int unreadCount;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ChatTileItem({
    super.key,
    required this.title,
    this.subtitle,
    this.time,
    this.icon,
    this.imagePath,
    this.initials,
    this.hasStatusDot = false,
    this.unreadCount = 0,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    if (imagePath != null && imagePath!.isNotEmpty) {
      avatarWidget = CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: AssetImage(imagePath!),
      );
    } else if (initials != null && initials!.isNotEmpty) {
      avatarWidget = CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          initials!,
          style: const TextStyle(
            color: ThemesColors.darkCharcoal,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      );
    } else {
      avatarWidget = CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade200,
        child: Icon(
          icon ?? Icons.storefront_outlined,
          color: ThemesColors.darkCharcoal,
          size: 22,
        ),
      );
    }

    if (hasStatusDot) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    Widget? trailingWidget;
    if (trailing != null) {
      trailingWidget = trailing;
    } else if (unreadCount > 0) {
      trailingWidget = Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: ThemesColors.darkCharcoal,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$unreadCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      trailingWidget = const Icon(
        Icons.chevron_right,
        color: Colors.grey,
        size: 20,
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: avatarWidget,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2, // Expands up to 2 lines for full name before ...
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ThemesColors.darkCharcoal,
                ),
              ),
            ),
            if (time != null) ...[
              const SizedBox(width: 8),
              Text(
                time!,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              )
            : null,
        trailing: trailingWidget,
      ),
    );
  }
}

// Alias for backwards compatibility
typedef ChatTitleItem = ChatTileItem;
