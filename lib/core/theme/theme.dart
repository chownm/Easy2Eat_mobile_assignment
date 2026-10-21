import 'package:flutter/material.dart';

class ThemesColors{
  static const Color brandOrange = Color(0xFFD1533B);
  static const Color freshGreen = Color(0xFF1E824C);
  static const Color promoYellow = Color(0xFFFFB300);
  static const Color darkCharcoal = Color(0xFF1C1A19);
  static const Color appSurface = Color(0xFFFFFFFF);

  // App Background
  static const Color scaffoldBackground = appSurface;
  static const Color cardBackground = appSurface;

  //Text Colors
  static const Color textPrimary = darkCharcoal;
  static const Color textOnPrimary = appSurface; // Text on top of Orange Button

  // Button Colors
  static const Color primaryButton = brandOrange;
  static const Color secondaryButton = darkCharcoal; // e.g., Apple Login button
  static const Color iconActive = brandOrange;
  static const Color iconInactive = Colors.grey; // Standard grey for unselected

  // Vendor & Rider Status Pipeline Colors
  static const Color statusPending = Colors.grey;
  static const Color statusPreparing = promoYellow;
  static const Color statusAlmostDone = promoYellow;
  static const Color statusDone = freshGreen;

  // Alerts & Highlights
  static const Color success = freshGreen;
  static const Color warning = promoYellow;
  static const Color error = brandOrange; // Reusing brand orange for destructive actions/errors
  static const Color starRating = promoYellow;
}

class ThemeTextStyle{

}