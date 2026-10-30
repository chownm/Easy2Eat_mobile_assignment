import 'package:flutter/material.dart';

// Delivery dispatch mode
enum DeliveryTimingMode {
  immediateDirect,
  scheduledShift,
}

// Blueprint for Drop-off Precision Hub
@immutable
class  DropOffPinModel {
  final String hubZoneTitle;
  final String microPinLandmark;
  final String referencePhotoNote;
  final double distanceKm;
  final bool isDirectUnstackedEligible;
  final String scheduledShiftWindow;

  const DropOffPinModel ({
    required this.hubZoneTitle,
    required this.microPinLandmark,
    required this.referencePhotoNote,
    required this.distanceKm,
    required this.isDirectUnstackedEligible,
    required this.scheduledShiftWindow,
  });

  DropOffPinModel copyWith({
    String? hubZoneTitle,
    String? microPinLandmark,
    String? referencePhotoNote,
    double? distanceKm,
    bool? isDirectUnstackedEligible,
    String? scheduledShiftWindow,
  }) {
    return DropOffPinModel(
        hubZoneTitle: hubZoneTitle ?? this.hubZoneTitle,
        microPinLandmark: microPinLandmark ?? this.microPinLandmark,
        referencePhotoNote: referencePhotoNote ?? this.referencePhotoNote,
        distanceKm: distanceKm ?? this.distanceKm,
        isDirectUnstackedEligible: isDirectUnstackedEligible ?? this.isDirectUnstackedEligible,
        scheduledShiftWindow: scheduledShiftWindow ?? this.scheduledShiftWindow,
    );
  }
}


// Blueprint for food item inside the Customer Cart
@immutable
class CartItemModel {
  final String id;
  final String merchantId;
  final String merchantName;
  final String title;
  final String dualLangSubtitle;
  final double unitPrice;
  final int quantity;
  final String customizationTag;
  final int dailyPortionsRemaining;

  const CartItemModel({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.title,
    required this.dualLangSubtitle,
    required this.unitPrice,
    required this.quantity,
    required this.customizationTag,
    required this.dailyPortionsRemaining,
  });

  CartItemModel copyWith({
    String? id,
    String? merchantId,
    String? merchantName,
    String? title,
    String? dualLangSubtitle,
    double? unitPrice,
    int? quantity,
    String? customizationTag,
    int? dailyPortionsRemaining,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      title: title ?? this.title,
      dualLangSubtitle: dualLangSubtitle ?? this.dualLangSubtitle,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      customizationTag: customizationTag ?? this.customizationTag,
      dailyPortionsRemaining: dailyPortionsRemaining ?? this.dailyPortionsRemaining,
    );
  }

  double get totalItemPrice => unitPrice * quantity;

  /// Serializes strictly to the Vendor's InventoryModel and Kitchen Ticket requirements[cite: 1].
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'itemID': id,                 // Maps to Vendor's InventoryModel.itemID[cite: 1]
      'itemName': title,            // Maps to Vendor's InventoryModel.itemName[cite: 1]
      'price': unitPrice,           // Maps to Vendor's InventoryModel.price[cite: 1]
      'quantity': quantity,
      'customizationTag': customizationTag,
      'merchantId': merchantId,
    };
  }

  /// Parses items back from JSON strings safely.
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['itemID'] ?? map['id'] ?? '',
      merchantId: map['merchantId'] ?? '',
      merchantName: map['merchantName'] ?? 'Store',
      title: map['itemName'] ?? map['title'] ?? 'Unknown Item',
      dualLangSubtitle: map['dualLangSubtitle'] ?? '',
      unitPrice: (map['price'] as num?)?.toDouble() ?? (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      customizationTag: map['customizationTag'] ?? map['dietaryNotes'] ?? '',
      dailyPortionsRemaining: 99,
    );
  }

  // STATIC MOCK DATA (Required for UI screens)

  static const DropOffPinModel mockDropOffPin = DropOffPinModel(
    hubZoneTitle: 'Cheras Traders Square • Block B',
    microPinLandmark: 'Front Gate Pillar 2 (Guardhouse Drop Table)',
    referencePhotoNote: 'gate_pillar_ref.jpg • Attached for Rider',
    distanceKm: 0.6,
    isDirectUnstackedEligible: true,
    scheduledShiftWindow: 'Today, 12:30 PM – 12:45 PM (Shift Break)',
  );

  static const List<CartItemModel> mockCartItems = <CartItemModel>[
    CartItemModel(
      id: 'cart_item_01',
      merchantId: 'merchant_v03_baiwei',
      merchantName: 'Bai Wei Mini Bowl 百味小碗菜',
      title: 'Spicy Braised Chicken Mini Bowl',
      dualLangSubtitle: '招牌辣子鸡小碗菜 • With Fragrant Rice',
      unitPrice: 12.90,
      quantity: 1,
      customizationTag: '= Less Spicy • 少辣',
      dailyPortionsRemaining: 24,
    ),
    CartItemModel(
      id: 'cart_item_02',
      merchantId: 'merchant_v02_chagee',
      merchantName: 'CHAGEE - Trader Square',
      title: 'Da Hong Pao Milk Tea (Large)',
      dualLangSubtitle: '大红袍牛乳茶 • Fresh Brewed Oolong',
      unitPrice: 11.90,
      quantity: 2,
      customizationTag: '= Less Sweet (50%) • Normal Ice',
      dailyPortionsRemaining: 36,
    ),
  ];

  static const List<String> dietaryQuickTags = <String>[
    'Less Spicy • 少辣',
    'No Cutlery • 无需餐具',
    'Sauce Separate • 酱料分开',
    'No Peanuts • 免花生',
    'Leave at Gate Pillar • 放门柱',
  ];

  static const double directUnstackedDeliveryFee = 1.50;
  static const double platformPackagingFee = 0.50;

  static double calculateSubtotal(List<CartItemModel> items) {
    return items.fold<double>(
      0.0,
          (double sum, CartItemModel item) => sum + item.totalItemPrice,
    );
  }
}