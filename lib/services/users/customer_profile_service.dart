import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/features/customer/models/customer_profile_model.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';
import 'package:flutter/foundation.dart';

class CustomerProfileService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches the user profile and applies global UI preference settings
  static Future<CustomerProfileModel?> getProfileAndSettings(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;

      final data = doc.data()!;

      // Inject global hardware/preference toggles into static UI trackers
      if (data.containsKey('defaultSubPinLandmark')) {
        OrderTrackingModel.defaultSubPinLandmark = data['defaultSubPinLandmark'];
      }
      if (data.containsKey('proximityBeaconEnabled')) {
        OrderTrackingModel.isProximityBeaconEnabled = data['proximityBeaconEnabled'];
      }

      return CustomerProfileModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  /// Pushes specific field updates to the user's document
  static Future<void> updateProfileField(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating profile field: $e');
    }
  }
}