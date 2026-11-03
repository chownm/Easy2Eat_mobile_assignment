import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class CustomerProfileModel {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? profilePhotoUrl;
  final String defaultSubPinLandmark;
  final String defaultDeliveryAddress;
  final String preferredLanguage; // 'en', 'ms', 'zh-cn'
  final bool proximityBeaconEnabled;
  final bool pushNotificationsEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CustomerProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePhotoUrl,
    this.defaultSubPinLandmark = 'Gate Pillar 2 (Table)',
    this.defaultDeliveryAddress = 'Cheras Traders Square • Block B',
    this.preferredLanguage = 'en',
    this.proximityBeaconEnabled = true,
    this.pushNotificationsEnabled = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor to deserialize from a Firestore DocumentSnapshot
  factory CustomerProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return CustomerProfileModel.fromMap(doc.id, data);
  }

  /// Factory constructor to deserialize from a Map
  factory CustomerProfileModel.fromMap(String docId, Map<String, dynamic> data) {
    return CustomerProfileModel(
      uid: docId,
      fullName: data['fullName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? data['phone'] ?? '',
      profilePhotoUrl: data['profilePhotoUrl'] ?? data['photoUrl'],
      defaultSubPinLandmark:
      data['defaultSubPinLandmark'] ?? data['subPin'] ?? 'Gate Pillar 2 (Table)',
      defaultDeliveryAddress:
      data['defaultDeliveryAddress'] ?? data['address'] ?? 'Cheras Traders Square • Block B',
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      proximityBeaconEnabled: data['proximityBeaconEnabled'] ?? true,
      pushNotificationsEnabled: data['pushNotificationsEnabled'] ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Serializes instance to a Firestore-compatible map
  Map<String, dynamic> toFirestoreMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': profilePhotoUrl,
      'defaultSubPinLandmark': defaultSubPinLandmark,
      'defaultDeliveryAddress': defaultDeliveryAddress,
      'preferredLanguage': preferredLanguage,
      'proximityBeaconEnabled': proximityBeaconEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  CustomerProfileModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePhotoUrl,
    String? defaultSubPinLandmark,
    String? defaultDeliveryAddress,
    String? preferredLanguage,
    bool? proximityBeaconEnabled,
    bool? pushNotificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerProfileModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      defaultSubPinLandmark:
      defaultSubPinLandmark ?? this.defaultSubPinLandmark,
      defaultDeliveryAddress:
      defaultDeliveryAddress ?? this.defaultDeliveryAddress,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      proximityBeaconEnabled:
      proximityBeaconEnabled ?? this.proximityBeaconEnabled,
      pushNotificationsEnabled:
      pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Static mock profile aligned with wireframe c_11
  static const CustomerProfileModel mockJoelIra = CustomerProfileModel(
    uid: 'mock_customer_joel_ira_01',
    fullName: 'Joel Ira',
    email: 'joel.ira@apu.edu.my',
    phoneNumber: '+60 12-892 4118',
    defaultSubPinLandmark: 'Gate Pillar 2 (Table)',
    defaultDeliveryAddress: 'Cheras Traders Square • Block B',
    preferredLanguage: 'en',
    proximityBeaconEnabled: true,
    pushNotificationsEnabled: true,
  );
}