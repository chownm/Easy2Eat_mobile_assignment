import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:easy2eat/features/customer/models/customer_profile_model.dart';
import 'package:easy2eat/features/customer/settings/widgets/customer_profile_screen.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/features/auth/presentation/login_screen.dart';

class SharedCustomerTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showPulseIndicator;
  final bool showBackButton;
  final bool showProfileButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogoutTap;
  final List<Widget>? customActions;

  const SharedCustomerTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showPulseIndicator = false,
    this.showBackButton = false,
    this.showProfileButton = true,
    this.onBackTap,
    this.onProfileTap,
    this.onLogoutTap,
    this.customActions,
  });

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomerEditProfileScreen(
          initialProfile: CustomerProfileModel.mockJoelIra,
        ),
      ),
    );
  }

  void _showDefaultLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ThemesColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log Out?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: ThemesColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your session?',
          style: TextStyle(
            color: ThemesColors.darkCharcoal.withValues(alpha: 0.75),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // 1. Pop dialog via rootNavigator
              Navigator.of(dialogContext, rootNavigator: true).pop();

              // 2. Sign out
              await UserSession.logout();

              // 3. Clear focus
              FocusManager.instance.primaryFocus?.unfocus();

              // 4. Push on post-frame callback
              if (context.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false,
                  );
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemesColors.brandOrange,
              foregroundColor: ThemesColors.textOnPrimary,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: <Widget>[
              // 1. Conditional Back button
              if (showBackButton) ...<Widget>[
                InkWell(
                  onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: ThemesColors.darkCharcoal,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // 2. Hyper-local pulse indicator
              if (showPulseIndicator && !showBackButton) ...<Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: ThemesColors.freshGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // 3. Title and optional subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ThemesColors.darkCharcoal,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 4. Custom Action or Profile
              if (customActions != null) ...<Widget>[
                ...customActions!,
              ]
              else if (showProfileButton) ...<Widget>[
                const SizedBox(width: 8),
                PopupMenuButton<ProfileMenuAction>(
                  tooltip: 'Account Options',
                  offset: const Offset(0, 48),
                  elevation: 4,
                  color: ThemesColors.appSurface,
                  surfaceTintColor: ThemesColors.appSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: ThemesColors.darkCharcoal.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  onSelected: (ProfileMenuAction action) {
                    if (action == ProfileMenuAction.viewProfile) {
                      if (onProfileTap != null) {
                        onProfileTap!.call();
                      } else {
                        _navigateToProfile(context);
                      }
                    } else if (action == ProfileMenuAction.logOut) {
                      if (onLogoutTap != null) {
                        onLogoutTap!.call();
                      } else {
                        _showDefaultLogoutDialog(context);
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<ProfileMenuAction>>[
                    const PopupMenuItem<ProfileMenuAction>(
                      value: ProfileMenuAction.viewProfile,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.person_outline_rounded,
                            color: ThemesColors.darkCharcoal,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'View Profile',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ThemesColors.darkCharcoal,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    const PopupMenuItem<ProfileMenuAction>(
                      value: ProfileMenuAction.logOut,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.logout_rounded,
                            color: ThemesColors.brandOrange,
                            size: 18,
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Log Out',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ThemesColors.brandOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: ThemesColors.darkCharcoal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: ThemesColors.appSurface,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        Divider(
          height: 1,
          thickness: 1,
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.08),
        ),
      ],
    );
  }
}