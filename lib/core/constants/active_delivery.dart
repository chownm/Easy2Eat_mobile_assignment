import 'package:flutter/material.dart';

class ActiveDeliveryState {
  static String _latestViewedRouteDeliveryNumber = ""; // Starts empty (no default order)
  static bool _vendorQrScanned = false;

  /// Keeps the delivery number of the LATEST action in View Route!
  static String get latestViewedRoute {
    if (_latestViewedRouteDeliveryNumber.isEmpty ||
        _latestViewedRouteDeliveryNumber == "Unknown Delivery" ||
        _latestViewedRouteDeliveryNumber == "Unknown User" ||
        _latestViewedRouteDeliveryNumber == "Unknown Delivery Number") {
      return "";
    }
    return _latestViewedRouteDeliveryNumber;
  }

  static set latestViewedRoute(String deliveryNumber) {
    if (deliveryNumber.isNotEmpty &&
        deliveryNumber != "Unknown Delivery" &&
        deliveryNumber != "Unknown User") {
      _latestViewedRouteDeliveryNumber = deliveryNumber;
      _vendorQrScanned = false; // Reset scan status for new delivery
    }
  }

  // Alias getters/setters for backwards compatibility
  static String get currentDeliveryNumber => latestViewedRoute;
  static set currentDeliveryNumber(String number) => latestViewedRoute = number;

  static bool get isVendorQrScanned => _vendorQrScanned;

  static void markVendorQrScanned() {
    _vendorQrScanned = true;
  }
}

/// Data Model for Chat List Items
class ChatItemData {
  final String title;
  final String subtitle;
  final String time;
  final String initials;
  final IconData? icon;

  ChatItemData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.initials,
    this.icon,
  });
}

/// Global Chat List State Manager (starts empty, generates chat tiles when rider taps Chat Vendor/Customer)
class ChatListState {
  static final List<ChatItemData> activeChats = [];

  /// Creates a new chat tile if it doesn't exist, or keeps the existing chat!
  static void startOrOpenChat(String chatTitle, BuildContext context) {
    final existingIndex = activeChats.indexWhere((chat) => chat.title == chatTitle);

    if (existingIndex == -1) {
      final bool isVendor = chatTitle.startsWith("Vendor");
      final now = TimeOfDay.now().format(context);

      activeChats.insert(
        0, // Add new chat at top
        ChatItemData(
          title: chatTitle,
          subtitle: isVendor ? "Chat started with vendor" : "Chat started with customer",
          time: now,
          initials: isVendor ? "VD" : "CD",
          icon: isVendor ? Icons.storefront_outlined : null,
        ),
      );
    }
  }
}
