import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';
import 'package:easy2eat/shared/widgets/settings/presentation/settingsSectionCard.dart';
import 'package:easy2eat/shared/widgets/settings/presentation/settingsTileItem.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/features/auth/presentation/login_screen.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';
import 'package:easy2eat/features/customer/models/customer_profile_model.dart';
import 'package:easy2eat/features/customer/settings/widgets/customer_profile_screen.dart';
import 'package:easy2eat/services/users/customer_profile_service.dart';

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  State<CustomerSettingsScreen> createState() => _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  // Temporary hardcoded active UID for development/viva until Auth is fully synced
  final String _activeUid = 'HLeKhWIeRgdh5KXfRwlp9Ai7zIP2';

  bool _pushNotifications = true;
  String _selectedLanguage = 'English';

  // Active Customer Profile state starts with mock, overwritten by fetch
  CustomerProfileModel _profile = CustomerProfileModel.mockJoelIra;

  @override
  void initState() {
    super.initState();
    _loadFirestoreProfile();
  }

  Future<void> _loadFirestoreProfile() async {
    final fetchedProfile = await CustomerProfileService.getProfileAndSettings(_activeUid);
    if (fetchedProfile != null && mounted) {
      setState(() {
        _profile = fetchedProfile;
      });
    }
  }

  final List<Map<String, String>> _languages = const [
    {'code': 'en', 'label': 'English (UK/US)', 'flag': '🇬🇧'},
    {'code': 'ms', 'label': 'Bahasa Melayu', 'flag': '🇲🇾'},
    {'code': 'zh-cn', 'label': '简体中文 (Chinese)', 'flag': '🇨🇳'},
  ];

  void _showLanguageSelectorDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ThemesColors.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: ThemesColors.darkCharcoal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select App Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: ThemesColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ..._languages.map((lang) {
                  final bool isSelected = _selectedLanguage == lang['label'];
                  return ListTile(
                    leading: Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      lang['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? ThemesColors.brandOrange : ThemesColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: ThemesColors.brandOrange)
                        : null,
                    onTap: () {
                      setState(() => _selectedLanguage = lang['label']!);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmDialog() {
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
              Navigator.pop(dialogContext);

              // 1. Properly sign out via your UserSession method
              await UserSession.logout();

              // 2. Navigate back to Login and clear the navigation backstack
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                );
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

  void _showEditSubPinDialog() {
    final TextEditingController controller =
    TextEditingController(text: OrderTrackingModel.defaultSubPinLandmark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemesColors.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Grab handle
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Edit Default Sub-Pin Landmark',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ThemesColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Sets the micro-drop landmark for couriers to drop your food',
              style: TextStyle(
                fontSize: 12,
                color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(
                color: ThemesColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                labelText: 'Sub-Pin Details',
                hintText: 'e.g., Gate Pillar 2 (Table), Lobby Guardhouse',
                labelStyle: TextStyle(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
                ),
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: ThemesColors.brandOrange,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: ThemesColors.brandOrange,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final String newLandmark = controller.text.trim();
                  if (newLandmark.isNotEmpty) {
                    setState(() {
                      OrderTrackingModel.defaultSubPinLandmark = newLandmark;
                    });
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Default sub-pin updated to "$newLandmark"'),
                        backgroundColor: ThemesColors.darkCharcoal,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemesColors.brandOrange,
                  foregroundColor: ThemesColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Save Landmark',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. MODAL: Displays Past Receipts
  void _showOrderHistoryModal() {
    final proof = OrderTrackingModel.defaultProof;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemesColors.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: ThemesColors.darkCharcoal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Order History & Receipts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ThemesColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Verified past deliveries with photographic drop-off proof',
                style: TextStyle(
                  fontSize: 12,
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ThemesColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: ThemesColors.darkCharcoal.withValues(alpha: 0.12),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: ThemesColors.freshGreen,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Order #E2E-89241',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: ThemesColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: ThemesColors.freshGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'DELIVERED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: ThemesColors.freshGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bai Wei Mini Bowl (C180 Hub)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: ThemesColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Drop-off: ${OrderTrackingModel.defaultSubPinLandmark}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
                                ),
                              ),
                              Text(
                                'Items: 2x Spicy Braised Chicken Bowl',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'RM 19.80',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: ThemesColors.brandOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: ThemesColors.darkCharcoal.withValues(alpha: 0.08),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2026-10-27 • 12:44 PM',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: ThemesColors.darkCharcoal.withValues(alpha: 0.5),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _showProofPhotoDialog(proof);
                          },
                          icon: const Icon(
                            Icons.photo_camera_outlined,
                            size: 16,
                            color: ThemesColors.brandOrange,
                          ),
                          label: const Text(
                            'View Gate Proof',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: ThemesColors.brandOrange,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. DIALOG: Displays Gate Drop-Off Photo Proof
  void _showProofPhotoDialog(DropOffProofModel proof) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ThemesColors.appSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gate Drop-Off Proof',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ThemesColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 180,
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.08),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      proof.localImageAsset != null
                          ? Image.asset(proof.localImageAsset!, fit: BoxFit.cover, width: double.infinity)
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: ThemesColors.brandOrange,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            proof.fileName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            proof.gpsAccuracyTag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                proof.caption,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: ThemesColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Timestamp: ${proof.timestampFormatted}',
                style: TextStyle(
                  fontSize: 11,
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
                ),
              ),
              Text(
                'Courier: ${proof.courierHandoffName}',
                style: TextStyle(
                  fontSize: 11,
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemesColors.brandOrange,
                  foregroundColor: ThemesColors.textOnPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Close Verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.appSurface,
      body: SafeArea(
        child: Column(
          children: [
            const SharedCustomerTopBar(
              title: 'Profile & Settings',
              showBackButton: false,
              showPulseIndicator: false,
              showProfileButton: false,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // 1. Profile Hero Card
                  _buildProfileHeroCard(),

                  const SizedBox(height: 16),

                  // 2. Section: Account Preferences
                  SettingsSectionCard(
                    title: 'Account Preferences',
                    children: [
                      SettingsTileItem(
                        icon: Icons.location_on_outlined,
                        iconColor: ThemesColors.brandOrange,
                        iconBgColor: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Default Sub-Pin Landmark',
                        // Dynamically reflects the current global landmark:
                        subtitle: '${OrderTrackingModel.defaultSubPinLandmark} • Cheras Traders Sq',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: _showEditSubPinDialog,
                      ),
                      SettingsTileItem(
                        icon: Icons.receipt_long_outlined,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Order History & Receipts',
                        subtitle: 'Past completed deliveries & proof photos',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: _showOrderHistoryModal,
                      ),
                      SettingsTileItem(
                        icon: Icons.credit_card_outlined,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Payment Methods',
                        subtitle: 'Touch n Go eWallet • Visa •••• 8821',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 3. Section: Alerts & Hardware Triggers
                  SettingsSectionCard(
                    title: 'Alerts & Hardware Triggers',
                    children: [
                      SettingsTileItem(
                        icon: Icons.notifications_none_rounded,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Push Notifications',
                        subtitle: 'Receive step updates on active tickets',
                        trailing: Switch(
                          value: _pushNotifications,
                          activeThumbColor: ThemesColors.appSurface,
                          activeTrackColor: ThemesColors.brandOrange,
                          inactiveTrackColor: ThemesColors.darkCharcoal.withValues(alpha: 0.15),
                          onChanged: (val) => setState(() => _pushNotifications = val),
                        ),
                      ),
                      // 100m Proximity Audio Beacon
                      SettingsTileItem(
                        icon: Icons.volume_up_outlined,
                        iconColor: ThemesColors.brandOrange,
                        iconBgColor: ThemesColors.brandOrange.withValues(alpha: 0.1),
                        title: '100m Proximity Audio Beacon',
                        subtitle: 'Play arrival chime when courier is within 100m',
                        trailing: Switch(
                          value: OrderTrackingModel.isProximityBeaconEnabled,
                          activeThumbColor: ThemesColors.appSurface,
                          activeTrackColor: ThemesColors.brandOrange,
                          inactiveTrackColor: ThemesColors.darkCharcoal.withValues(alpha: 0.15),
                          onChanged: (bool value) {
                            setState(() {
                              OrderTrackingModel.isProximityBeaconEnabled = value;
                            });
                            // Push toggle immediately to Firestore
                            CustomerProfileService.updateProfileField(
                              _activeUid,
                              {'proximityBeaconEnabled': value},
                            );
                          },
                        ),
                      ),
                      // App Language Selector
                      SettingsTileItem(
                        icon: Icons.g_translate_rounded,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'App Interface Language',
                        subtitle: _selectedLanguage,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedLanguage.split(' ').first,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: ThemesColors.brandOrange,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: ThemesColors.iconInactive,
                              size: 20,
                            ),
                          ],
                        ),
                        onTap: _showLanguageSelectorDialog,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 4. Section: Support & Information
                  SettingsSectionCard(
                    title: 'Support & Information',
                    children: [
                      SettingsTileItem(
                        icon: Icons.help_outline_rounded,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Help Center & Support',
                        subtitle: 'Live support corridor & delivery guidelines',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: () {},
                      ),
                      SettingsTileItem(
                        icon: Icons.description_outlined,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Terms & Academic Project Info',
                        subtitle: 'APU CT124-3-2-MAE Level 2',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 5. Log Out Button (Wireframe Button 2)
                  OutlinedButton.icon(
                    onPressed: _showLogoutConfirmDialog,
                    icon: const Icon(Icons.logout_rounded, color: ThemesColors.brandOrange, size: 18),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ThemesColors.brandOrange,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: ThemesColors.appSurface,
                      minimumSize: const Size(double.infinity, 48),
                      side: BorderSide(
                        color: ThemesColors.darkCharcoal.withValues(alpha: 0.18),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer Version Tag
                  Center(
                    child: Text(
                      'Easy2Eat v1.0.0 (Build 2026.10)',
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemesColors.darkCharcoal.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeroCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemesColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.12),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ThemesColors.darkCharcoal.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 28,
              color: ThemesColors.darkCharcoal,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemesColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _profile.phoneNumber, // Reads dynamically!
                  style: TextStyle(
                    fontSize: 12,
                    color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final updated = await Navigator.push<CustomerProfileModel>(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerEditProfileScreen(
                    initialProfile: _profile,
                    onProfileSaved: (newProfile) {
                      setState(() => _profile = newProfile);
                    },
                  ),
                ),
              );
              if (updated != null) {
                setState(() => _profile = updated);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemesColors.darkCharcoal.withValues(alpha: 0.07),
              foregroundColor: ThemesColors.darkCharcoal,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}