import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  final double unitPrice;
  final String imageUrl;
  final bool isInStock;

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
    required this.unitPrice,
    required this.imageUrl,
    required this.isInStock,
  });

  /// Consumes the Vendor teammate's 'inventory' collection document schema directly[cite: 24, 25].
  factory MerchantModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};

    final String name = data['itemName'] ??
        data['title'] ??
        data['vendorName'] ??
        'Special Dish';
    final double price = (data['price'] as num?)?.toDouble() ?? 10.0;
    final int stock = (data['availableStock'] as num?)?.toInt() ??
        (data['dailyPortionsRemaining'] as num?)?.toInt() ??
        0;
    final String status =
    (data['inventoryStatus'] ?? 'in_stock').toString().toLowerCase();
    final bool available = status == 'in_stock' && stock > 0;

    return MerchantModel(
      id: doc.id,
      title: name,
      dualLangSubtitle: data['description'] ??
          (stock > 0
              ? 'C180 Food Court • $stock portions remaining'
              : 'Sold out for current shift'),
      categoryTag: data['categoryTag'] ?? 'Main Kitchen',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.8,
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.6,
      hubRouteLabel: data['storeLocation'] ?? 'C180 Food Court',
      executionCostAndEta:
      'RM ${price.toStringAsFixed(2)} • 10 mins • RM 1.50 Delivery',
      operationalTags: List<String>.from(
        data['operationalTags'] ??
            <String>[
              'Direct <1km',
              available ? '$stock Portions Left' : 'Sold Out',
              'Kitchen Live',
            ],
      ),
      dailyPortionsRemaining: stock,
      isDirectUnstackedEligible: available,
      unitPrice: price,
      imageUrl: data['imageURL'] ?? '',
      isInStock: available,
    );
  }
}