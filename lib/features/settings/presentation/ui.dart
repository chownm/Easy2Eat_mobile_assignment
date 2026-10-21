import 'package:easy2eat/features/rider/presentation/riderAppBar.dart';
import 'package:easy2eat/features/settings/presentation/settingsTileItem.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'settingsSectionCard.dart';

import '../../../core/enum/user_role.dart';
import '../../../shared/widgets/shared_navigation_bar.dart';

class settingPage extends StatefulWidget {
  const settingPage({super.key});

  @override
  State<settingPage> createState() => _settingPageState();
}

class _settingPageState extends State<settingPage> {
  get _currentIndex => 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: riderAppBar(title: "Settings"),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SettingsSectionCard(
                title: 'Account & Security',
                children: [
                  SettingsTileItem(
                    icon: Icons.person_outline,
                    title: 'Profile Details',
                    subtitle: 'Name, phone number, and email',
                    onTap: () {},
                  ),
                  SettingsTileItem(
                    icon: Icons.lock_outline,
                    title: 'Password & Security',
                    subtitle: 'Manage password and authentication',
                    onTap: () {},
                  ),
                  SettingsTileItem(
                    icon: Icons.delete_outline,
                    iconColor: Colors.red,
                    iconBgColor: Colors.black,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove account and user data',
                    onTap: () {},
                  ),
                ],
              ),
              SettingsSectionCard(
                title: 'Support & Term',
                children: [
                  SettingsTileItem(
                    icon: Icons.question_answer,
                    title: 'Help Center & Support',
                    subtitle: 'Live chat, FAQs, and contact us',
                    onTap: () {},
                  ),
                  SettingsTileItem(
                    icon: Icons.policy,
                    title: 'Privacy Policy & Terms',
                    subtitle: 'Service agreement',
                    onTap: () {},
                  ),
                ],
              ),
            ]
          )
        ),
      ),
      bottomNavigationBar: SharedNavigationBar(
        currentIndex: _currentIndex,
        role: UserRole.rider,
        onTap: (int index) {},
      ),
    );
  }
}
