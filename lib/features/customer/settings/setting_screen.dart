import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/auth/presentation/login_screen.dart';
import 'package:easy2eat/features/customer/models/customer_profile_model.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';
import 'package:easy2eat/features/customer/settings/widgets/customer_profile_screen.dart';
import 'package:easy2eat/features/customer/tracking/tracking_screen.dart'; // <--- ADD THIS
import 'package:easy2eat/services/users/customer_profile_service.dart';
import 'package:easy2eat/shared/widgets/settings/presentation/settingsSectionCard.dart';
import 'package:easy2eat/shared/widgets/settings/presentation/settingsTileItem.dart';
import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  State<CustomerSettingsScreen> createState() => _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  // 1. Dynamic UID derived from authenticated Firebase session
  String get _activeUid =>
      UserSession.currentUid ??
          FirebaseAuth.instance.currentUser?.uid ??
          'CUST-101';

  bool _pushNotifications = true;
  String _selectedLanguage = 'English';

  CustomerProfileModel? _profile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadFirestoreProfile();
  }

  Future<void> _loadFirestoreProfile() async {
    final fetchedProfile =
    await CustomerProfileService.getProfileAndSettings(_activeUid);
    if (mounted) {
      setState(() {
        _profile = fetchedProfile ??
            CustomerProfileModel(
              uid: _activeUid,
              fullName: FirebaseAuth.instance.currentUser?.displayName ??
                  'Valued Customer',
              email: FirebaseAuth.instance.currentUser?.email ?? '',
              phoneNumber:
              FirebaseAuth.instance.currentUser?.phoneNumber ??
                  '+60 12-000 0000',
              defaultSubPinLandmark:
              OrderTrackingModel.defaultSubPinLandmark,
            );
        _isLoadingProfile = false;
      });
    }
  }

  final _languages = const [
    {'code': 'en', 'label': 'English (UK/US)', 'flag': '🇬🇧'},
    {'code': 'ms', 'label': 'Bahasa Melayu', 'flag': '🇲🇾'},
    {'code': 'zh-cn', 'label': '简体中文 (Chinese)', 'flag': '🇨🇳'},
  ];

  // Change Password
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isUpdating = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemesColors.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
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
                    'Change Account Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ThemesColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter your current password and choose a new one.',
                    style: TextStyle(
                      fontSize: 12,
                      color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),

                  // 1. Current Password
                  TextField(
                    controller: currentPasswordController,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      isDense: true,
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setModalState(() => obscureCurrent = !obscureCurrent),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. New Password
                  TextField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      isDense: true,
                      prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setModalState(() => obscureNew = !obscureNew),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Confirm New Password
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      isDense: true,
                      prefixIcon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setModalState(() => obscureConfirm = !obscureConfirm),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUpdating
                          ? null
                          : () async {
                        final currentPass = currentPasswordController.text.trim();
                        final newPass = newPasswordController.text.trim();
                        final confirmPass = confirmPasswordController.text.trim();

                        if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                          setModalState(() => errorMessage = 'All password fields are required.');
                          return;
                        }
                        if (newPass.length < 6) {
                          setModalState(() => errorMessage = 'New password must be at least 6 characters.');
                          return;
                        }
                        if (newPass != confirmPass) {
                          setModalState(() => errorMessage = 'New passwords do not match.');
                          return;
                        }

                        setModalState(() {
                          isUpdating = true;
                          errorMessage = null;
                        });

                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null && user.email != null) {
                            // Re-authenticate user with Firebase Auth
                            final cred = EmailAuthProvider.credential(
                              email: user.email!,
                              password: currentPass,
                            );
                            await user.reauthenticateWithCredential(cred);
                            await user.updatePassword(newPass);
                          }

                          // Update plain text password field in Firestore users doc
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(_activeUid)
                              .update({'password': newPass});

                          if (!mounted) return;
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password updated successfully!'),
                              backgroundColor: ThemesColors.freshGreen,
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          setModalState(() {
                            isUpdating = false;
                            if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
                              errorMessage = 'Incorrect current password.';
                            } else {
                              errorMessage = e.message ?? 'Failed to update password.';
                            }
                          });
                        } catch (e) {
                          setModalState(() {
                            isUpdating = false;
                            errorMessage = 'Error updating password: $e';
                          });
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
                      child: isUpdating
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                          : const Text(
                        'Update Password',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Language Selector (coming soon in 2027)
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
                    leading:
                    Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                    title: Text(
                      lang['label']!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? ThemesColors.brandOrange
                            : ThemesColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded,
                        color: ThemesColors.brandOrange)
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
              Navigator.of(dialogContext, rootNavigator: true).pop();
              await UserSession.logout();
              FocusManager.instance.primaryFocus?.unfocus();

              if (mounted) {
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
                    // Persist to user settings in Firestore
                    CustomerProfileService.updateProfileField(
                      _activeUid,
                      {'defaultSubPinLandmark': newLandmark},
                    );
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text('Default sub-pin updated to "$newLandmark"'),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemesColors.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
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

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('customerID', isEqualTo: _activeUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ThemesColors.brandOrange,
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: ThemesColors.darkCharcoal
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No past orders yet',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: ThemesColors.darkCharcoal,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Orders placed will appear here with live receipts.',
                              style: TextStyle(
                                fontSize: 12,
                                color: ThemesColors.darkCharcoal
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: docs.length,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order =
                        docs[index].data() as Map<String, dynamic>;
                        final String orderId =
                            order['orderID'] ?? order['orderId'] ?? docs[index].id;
                        final String status =
                        (order['status'] ?? order['stage'] ?? 'confirmed')
                            .toString()
                            .toUpperCase();
                        final String vendor =
                            order['vendorName'] ?? 'Campus Merchant';
                        final String items =
                            order['orderItems'] ?? '1x Meal Order';
                        final double total = (order['totalPrice'] as num?)
                            ?.toDouble() ??
                            0.0;
                        final String? proofPhotoUrl = order['proofUrl'] ?? order['proofPhotoUrl'] ?? order['dropOffProofPhotoUrl'];
                        final String createdAt =
                            (order['createdAt'] ?? 'Just now')
                                .toString()
                                .split('T')
                                .first;

                        final bool isDelivered = status == 'DELIVERED';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ThemesColors.cardBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ThemesColors.darkCharcoal
                                  .withValues(alpha: 0.12),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isDelivered
                                            ? Icons.check_circle_rounded
                                            : Icons.access_time_rounded,
                                        color: isDelivered
                                            ? ThemesColors.freshGreen
                                            : ThemesColors.brandOrange,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Order #$orderId',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: ThemesColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: isDelivered
                                          ? ThemesColors.freshGreen
                                          .withValues(alpha: 0.12)
                                          : ThemesColors.brandOrange
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDelivered
                                            ? ThemesColors.freshGreen
                                            : ThemesColors.brandOrange,
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vendor,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: ThemesColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          items,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: ThemesColors.darkCharcoal
                                                .withValues(alpha: 0.65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'RM ${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: ThemesColors.brandOrange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(
                                height: 1,
                                color: ThemesColors.darkCharcoal
                                    .withValues(alpha: 0.08),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    createdAt,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                      color: ThemesColors.darkCharcoal.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // 1. Inspect on Tracking Map & Pipeline
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(sheetContext);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CustomerTrackingScreen(
                                                orderId: orderId,
                                                showBackButton: true, // <-- Enables back button
                                              ),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Track Order',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: ThemesColors.darkCharcoal,
                                          ),
                                        ),
                                      ),

                                      // 2. Gate Photo Proof Button
                                      if (isDelivered && proofPhotoUrl != null) ...[
                                        const SizedBox(width: 6),
                                        TextButton.icon(
                                          onPressed: () {
                                            Navigator.pop(sheetContext);
                                            _showProofPhotoDialog(
                                              orderId: orderId,
                                              photoUrl: proofPhotoUrl,
                                              riderName: order['riderName'],
                                              landmark: order['subPin'] ?? order['location'] ?? OrderTrackingModel.defaultSubPinLandmark,
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.photo_camera_outlined,
                                            size: 15,
                                            color: ThemesColors.brandOrange,
                                          ),
                                          label: const Text(
                                            'Gate Proof',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: ThemesColors.brandOrange,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 2. DIALOG: Displays Gate Drop-Off Photo Proof
  void _showProofPhotoDialog({
    required String orderId,
    required String photoUrl,
    String? riderName,
    required String landmark,
  }) {
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
                  Text(
                    'Drop-Off Proof #$orderId',
                    style: const TextStyle(
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
                child: Image.network(
                  photoUrl,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 190,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ThemesColors.brandOrange,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 190,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Delivered to $landmark',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: ThemesColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Courier: ${riderName ?? 'Verified Campus Rider'}',
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
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
                        iconBgColor:
                        ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Default Sub-Pin Landmark',
                        subtitle:
                        '${OrderTrackingModel.defaultSubPinLandmark} • Cheras Traders Sq',
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: _showEditSubPinDialog,
                      ),
                      SettingsTileItem(
                        icon: Icons.receipt_long_outlined,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor:
                        ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Order History & Receipts',
                        subtitle: 'Past completed deliveries & proof photos',
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: _showOrderHistoryModal,
                      ),
                      SettingsTileItem(
                        icon: Icons.credit_card_outlined,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor:
                        ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Payment Methods',
                        subtitle: 'Touch n Go eWallet • Online Banking (FPX)',
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: () {},
                      ),
                      SettingsTileItem(
                        icon: Icons.lock_outline_rounded,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor:
                        ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Change Password',
                        subtitle: 'Update account login credentials',
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: _showChangePasswordDialog,
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
                        iconBgColor:
                        ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Push Notifications',
                        subtitle: 'Receive step updates on active tickets',
                        trailing: Switch(
                          value: _pushNotifications,
                          activeThumbColor: ThemesColors.appSurface,
                          activeTrackColor: ThemesColors.brandOrange,
                          inactiveTrackColor: ThemesColors.darkCharcoal
                              .withValues(alpha: 0.15),
                          onChanged: (val) =>
                              setState(() => _pushNotifications = val),
                        ),
                      ),
                      SettingsTileItem(
                        icon: Icons.volume_up_outlined,
                        iconColor: ThemesColors.brandOrange,
                        iconBgColor:
                        ThemesColors.brandOrange.withValues(alpha: 0.1),
                        title: '100m Proximity Audio Beacon',
                        subtitle:
                        'Play arrival chime when courier is within 100m',
                        trailing: Switch(
                          value: OrderTrackingModel.isProximityBeaconEnabled,
                          activeThumbColor: ThemesColors.appSurface,
                          activeTrackColor: ThemesColors.brandOrange,
                          inactiveTrackColor: ThemesColors.darkCharcoal
                              .withValues(alpha: 0.15),
                          onChanged: (bool value) {
                            setState(() {
                              OrderTrackingModel.isProximityBeaconEnabled =
                                  value;
                            });
                            CustomerProfileService.updateProfileField(
                              _activeUid,
                              {'proximityBeaconEnabled': value},
                            );
                          },
                        ),
                      ),
                      SettingsTileItem(
                        icon: Icons.g_translate_rounded,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor:
                        ThemesColors.darkCharcoal.withValues(alpha: 0.05),
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
                            const Icon(
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
                        iconBgColor:
                        ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Help Center & Support',
                        subtitle:
                        'Live support corridor & delivery guidelines',
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: () {},
                      ),
                      SettingsTileItem(
                        icon: Icons.description_outlined,
                        iconColor: ThemesColors.darkCharcoal,
                        iconBgColor:
                        ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                        title: 'Terms & Academic Project Info',
                        subtitle: 'APU CT124-3-2-MAE Level 2',
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: ThemesColors.iconInactive,
                          size: 20,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 5. Log Out Button
                  OutlinedButton.icon(
                    onPressed: _showLogoutConfirmDialog,
                    icon: const Icon(Icons.logout_rounded,
                        color: ThemesColors.brandOrange, size: 18),
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
                        color: ThemesColors.darkCharcoal
                            .withValues(alpha: 0.18),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Easy2Eat v1.0.0 (Build 2026.10)',
                      style: TextStyle(
                        fontSize: 11,
                        color: ThemesColors.darkCharcoal
                            .withValues(alpha: 0.45),
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
    if (_isLoadingProfile) {
      return Container(
        height: 78,
        decoration: BoxDecoration(
          color: ThemesColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: ThemesColors.brandOrange,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final profile = _profile!;

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
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemesColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.phoneNumber,
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
                    initialProfile: profile,
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
              backgroundColor:
              ThemesColors.darkCharcoal.withValues(alpha: 0.07),
              foregroundColor: ThemesColors.darkCharcoal,
              elevation: 0,
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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