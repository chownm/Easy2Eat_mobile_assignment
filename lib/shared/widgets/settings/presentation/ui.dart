import 'package:easy2eat/core/routing/RiderRouting.dart';
import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:easy2eat/shared/widgets/settings/presentation/settingsTileItem.dart';
import 'package:easy2eat/shared/widgets/settings/presentation/settingsSectionCard.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/enum/user_role.dart';
import 'package:easy2eat/shared/widgets/shared_navigation_bar.dart';
import 'package:easy_localization/easy_localization.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  int get _currentIndex => 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RiderAppBar(title: 'settings'.tr()),
      body: Center(
          child: Scrollbar(
              child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SettingsSectionCard(
                            title: 'accountAndSecurity'.tr(),
                            children: [
                              SettingsTileItem(
                                icon: Icons.person_outline,
                                title: 'profileDetails'.tr(),
                                subtitle: 'profileDetailsSubtitle'.tr(),
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.profileDetails);
                                },
                              ),
                              SettingsTileItem(
                                icon: Icons.lock_outline,
                                title: 'passwordAndSecurity'.tr(),
                                subtitle: 'passwordAndSecuritySubtitle'.tr(),
                                onTap: () {},
                              ),
                            ],
                          ),
                          SettingsSectionCard(
                            title: 'supportAndTerm'.tr(),
                            children: [
                              SettingsTileItem(
                                icon: Icons.question_answer,
                                title: 'helpCenterAndSupport'.tr(),
                                subtitle: 'helpCenterSubtitle'.tr(),
                                onTap: () {},
                              ),
                            ],
                          ),
                          SettingsSectionCard(
                            title: 'language'.tr(),
                            children: [
                              SettingsTileItem(
                                icon: Icons.language,
                                title: 'preferredLanguage'.tr(),
                                onTap: () {
                                  Navigator.pushNamed(context, AppRoutes.internationalize);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]
              )
          )
      ),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.rider,
        onTap: (int index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, AppRoutes.riderHome);
          }
          if (index == 1) {
            Navigator.pushReplacementNamed(context, AppRoutes.riderMaps);
          }
          if (index == 2) {
            Navigator.pushReplacementNamed(context, AppRoutes.riderChat);
          }
        },
      ),
    );
  }
}

// Alias for backwards compatibility
typedef settingPage = SettingsPage;
