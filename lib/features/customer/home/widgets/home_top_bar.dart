import 'package:flutter/material.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:easy2eat/core/theme/theme.dart';



// Component 1: Top App Bar
class CustomerTopAppBar extends StatelessWidget {
  final String title;

  const CustomerTopAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Hyper-local pulse indicator
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: ThemesColors.freshGreen,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),

        Expanded(child: Column(
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
            Text(
              'Hyper-Local <1km Unstacked Dispatch Active',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),),
        const SizedBox(width: 8),

        // Profile Button with Pop-out Container
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
          onSelected: (ProfileMenuAction action){
            //Will connect to auth providers in the Riverpod phase
          },
          itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<ProfileMenuAction>>[
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
                    ),),
                ],
              ),
            ),
            PopupMenuDivider(
              height: 1,
            ),
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
                    ),),
                ],
              ),
            )
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
        )
      ],
    );
  }
}