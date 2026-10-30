import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/features/customer/models/customer_profile_model.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';
import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerEditProfileScreen extends StatefulWidget {
  final CustomerProfileModel initialProfile;
  final ValueChanged<CustomerProfileModel>? onProfileSaved;

  const CustomerEditProfileScreen({
    super.key,
    required this.initialProfile,
    this.onProfileSaved,
  });

  @override
  State<CustomerEditProfileScreen> createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends State<CustomerEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _subPinController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialProfile.fullName);
    _phoneController =
        TextEditingController(text: widget.initialProfile.phoneNumber);
    _emailController = TextEditingController(text: widget.initialProfile.email);
    _addressController =
        TextEditingController(text: widget.initialProfile.defaultDeliveryAddress);
    _subPinController =
        TextEditingController(text: widget.initialProfile.defaultSubPinLandmark);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _subPinController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedProfile = widget.initialProfile.copyWith(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      defaultDeliveryAddress: _addressController.text.trim(),
      defaultSubPinLandmark: _subPinController.text.trim(),
      updatedAt: DateTime.now(),
    );

    // 1. Sync global landmark in OrderTrackingModel
    OrderTrackingModel.defaultSubPinLandmark =
        updatedProfile.defaultSubPinLandmark;

    // 2. Persist to Firestore if user is authenticated
    final uid = UserSession.currentUid ?? widget.initialProfile.uid;
    try {
      if (UserSession.isLoggedIn) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .set(updatedProfile.toFirestoreMap(), SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Firestore profile save warning (offline/mock mode): $e');
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    // 3. Callback to parent Settings state
    widget.onProfileSaved?.call(updatedProfile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: ThemesColors.freshGreen,
      ),
    );

    Navigator.pop(context, updatedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.appSurface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with back arrow enabled, profile avatar hidden
            SharedCustomerTopBar(
              title: 'Edit Profile',
              subtitle: 'Customer Information',
              showBackButton: true,
              showProfileButton: false,
              onBackTap: () => Navigator.pop(context),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Avatar with Edit Camera Overlay
                      _buildAvatarPicker(),

                      const SizedBox(height: 24),

                      // 2. Input Fields
                      _buildTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'e.g. Joel Ira',
                        icon: Icons.person_outline_rounded,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Please enter your name'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '+60 12-345 6789',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Please enter your phone number'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'joel.ira@apu.edu.my',
                        icon: Icons.email_outlined,
                        readOnly: true, // Tied to Firebase Auth
                      ),

                      const SizedBox(height: 20),

                      const Divider(
                        color: Color(0x1F1C1A19),
                        thickness: 1,
                      ),

                      const SizedBox(height: 16),

                      // Section Header for Default Address & Landmark
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Delivery Location & Sub-Pin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: ThemesColors.darkCharcoal.withValues(alpha: 0.8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: _addressController,
                        label: 'Primary Delivery Residence',
                        hint: 'Cheras Traders Square • Block B',
                        icon: Icons.apartment_outlined,
                      ),

                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _subPinController,
                        label: 'Default Sub-Pin Landmark',
                        hint: 'e.g. Gate Pillar 2 (Table), Lobby Guardhouse',
                        icon: Icons.location_on_outlined,
                      ),

                      const SizedBox(height: 32),

                      // 3. Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSaveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemesColors.brandOrange,
                            foregroundColor: ThemesColors.textOnPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ThemesColors.appSurface,
                            ),
                          )
                              : const Text(
                            'Save Profile Changes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: ThemesColors.darkCharcoal.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(
              color: ThemesColors.brandOrange,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 52,
            color: ThemesColors.darkCharcoal,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: ThemesColors.brandOrange,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 16,
            color: ThemesColors.appSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: readOnly
            ? ThemesColors.darkCharcoal.withValues(alpha: 0.5)
            : ThemesColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: ThemesColors.darkCharcoal, size: 20),
        filled: readOnly,
        fillColor: readOnly
            ? ThemesColors.darkCharcoal.withValues(alpha: 0.04)
            : ThemesColors.appSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemesColors.darkCharcoal.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: ThemesColors.brandOrange,
            width: 2,
          ),
        ),
      ),
    );
  }
}