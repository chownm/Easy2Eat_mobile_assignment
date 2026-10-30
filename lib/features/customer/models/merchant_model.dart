import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Profile Menu Action Enum
enum ProfileMenuAction {
  viewProfile,
  logOut,
}

@immutable
class MerchantModel {
  final String id;
  final String title;
  final String dualLangSubtitle;
  final String categoryTag;
  final double rating;
  final double distanceKm;
  final String hubRouteLabel;
  final String executionCostAndEta;
  final List<String> operationalTags;
  final int dailyPortionsRemaining;
  final bool isDirectUnstackedEligible;

  const MerchantModel({
    required this.id,
    required this.title,
    required this.dualLangSubtitle,
    required this.categoryTag,
    required this.rating,
    required this.distanceKm,
    required this.hubRouteLabel,
    required this.executionCostAndEta,
    required this.operationalTags,
    required this.dailyPortionsRemaining,
    required this.isDirectUnstackedEligible,
  });

  /// Consumes the Vendor teammate's 'VendorModel' backend schema[cite: 3].
  factory MerchantModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};

    return MerchantModel(
      id: doc.id,
      title: data['vendorName'] ?? data['storeName'] ?? data['title'] ?? 'Unnamed Store', // Maps to VendorModel[cite: 3]
      dualLangSubtitle: data['description'] ?? '',
      categoryTag: data['categoryTag'] ?? 'General',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.6,
      hubRouteLabel: data['storeLocation'] ?? data['hubRouteLabel'] ?? 'Unknown Location', // Maps to VendorModel[cite: 3]
      executionCostAndEta: data['executionCostAndEta'] ?? 'RM 1.50 Delivery',
      operationalTags: List<String>.from(data['operationalTags'] ?? <String>['Direct <1km']),
      dailyPortionsRemaining: (data['dailyPortionsRemaining'] as num?)?.toInt() ?? 99,
      isDirectUnstackedEligible: data['isOpen'] ?? true, // Uses Vendor's 'isOpen' boolean[cite: 3]
    );
  }
}