import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/shared/widgets/settings/presentation/settingsSectionCard.dart';
import 'package:easy2eat/shared/widgets/settings/presentation/settingsTileItem.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/features/auth/presentation/login_screen.dart';

class VendorSettingPage extends StatefulWidget {
  const VendorSettingPage({super.key});

  @override
  State<VendorSettingPage> createState() => _VendorSettingPageState();
}

class _VendorSettingPageState extends State<VendorSettingPage> {

  /// Safely updates or creates fields in the Firestore 'users' collection using merge option.
  Future<void> _updateField(String activeUid, Map<String, dynamic> dataToUpdate) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(activeUid)
          .set({
        ...dataToUpdate,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
      );
    }
  }

  /// Displays an input dialog to modify or initialize optional user/store profile fields.
  void _showEditDialog(BuildContext context, String activeUid, String title, String currentVal, String firestoreKey) {
    final TextEditingController controller = TextEditingController(text: currentVal);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter $title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateField(activeUid, {firestoreKey: controller.text.trim()});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Handles user logout and clears the local session role.
  void _handleLogout(BuildContext context) {
    UserSession.logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeUid = UserSession.currentUid ?? FirebaseAuth.instance.currentUser?.uid;

    if (activeUid == null) {
      return Scaffold(
        backgroundColor: ThemesColors.scaffoldBackground,
        appBar: AppBar(
          title: const Text('Vendor Settings', style: TextStyle(color: ThemesColors.textPrimary)),
          backgroundColor: ThemesColors.appSurface,
        ),
        body: const Center(
          child: Text(
            'Error: No active user session found. Please log in again.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ThemesColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ThemesColors.appSurface,
        elevation: 0,
        title: const Text(
          'Vendor Settings',
          style: TextStyle(
            color: ThemesColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(activeUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Fallback to an empty map gracefully if fields or document are missing
          final userData = (snapshot.data?.data() as Map<String, dynamic>?) ?? {};

          final String vendorName = userData['fullName'] ?? userData['name'] ?? 'My Store';
          final String phoneNumber = userData['phoneNumber'] ?? '';
          final String storeLocation = userData['defaultDeliveryAddress'] ?? userData['storeLocation'] ?? '';
          final String imageURL = userData['profilePhotoUrl'] ?? '';
          final bool isOpen = userData['isOpen'] ?? true; // Default to true if not initialized

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. Vendor Profile Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: imageURL.isNotEmpty ? NetworkImage(imageURL) : null,
                      child: imageURL.isEmpty
                          ? const Icon(Icons.storefront, size: 32, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendorName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: ThemesColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Role: Vendor',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Store Operations (Toggles isOpen status)
              SettingsSectionCard(
                title: 'Store Operations',
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Store Open Status',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      isOpen ? 'Accepting incoming customer orders' : 'Currently closed for orders',
                      style: TextStyle(
                        color: isOpen ? Colors.green.shade700 : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    value: isOpen,
                    activeColor: ThemesColors.brandOrange,
                    onChanged: (bool value) {
                      _updateField(activeUid, {'isOpen': value});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Store Information (Dynamic fields configuration)
              SettingsSectionCard(
                title: 'Store Information',
                children: [
                  SettingsTileItem(
                    icon: Icons.store_mall_directory_outlined,
                    title: 'Store Name',
                    subtitle: vendorName,
                    onTap: () => _showEditDialog(context, activeUid, 'Store Name', vendorName, 'fullName'),
                  ),
                  SettingsTileItem(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    subtitle: phoneNumber.isNotEmpty ? phoneNumber : 'Tap to set phone number',
                    onTap: () => _showEditDialog(context, activeUid, 'Phone Number', phoneNumber, 'phoneNumber'),
                  ),
                  SettingsTileItem(
                    icon: Icons.location_on_outlined,
                    title: 'Store Location',
                    subtitle: storeLocation.isNotEmpty ? storeLocation : 'Tap to set store location',
                    onTap: () => _showEditDialog(context, activeUid, 'Store Location', storeLocation, 'storeLocation'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Account Security & Logout
              SettingsSectionCard(
                title: 'Account Security',
                children: [
                  SettingsTileItem(
                    icon: Icons.logout_rounded,
                    title: 'Log Out',
                    iconColor: Colors.red,
                    onTap: () => _handleLogout(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}