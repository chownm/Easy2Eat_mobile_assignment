import 'package:flutter/material.dart';

// Profile Menu Action Enum
enum ProfileMenuAction {
  viewProfile,
  logOut,
}

@immutable
class StaticMerchantModel {
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

  const StaticMerchantModel({
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
}