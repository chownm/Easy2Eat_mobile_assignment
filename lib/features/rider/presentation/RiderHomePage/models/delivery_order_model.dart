/// Database Model for Food Item
class FoodItemData {
  final int quantity;
  final String name;
  final String price;

  const FoodItemData({
    required this.quantity,
    required this.name,
    required this.price,
  });

  factory FoodItemData.fromMap(Map<String, dynamic> map) {
    return FoodItemData(
      quantity: map['qty'] as int? ?? map['quantity'] as int? ?? 1,
      name: map['name'] as String? ?? 'Item',
      price: map['price'] as String? ?? 'RM0.00',
    );
  }
}

/// Database Model for Delivery Order (Matching Standard ORD Schema)
class DeliveryOrderData {
  final String deliveryId;
  final String orderTime;
  final String pickupLocation;
  final String dropOffLocation;
  final String earningAmount;
  final String status;
  final String? assignedRiderId;
  bool isDelivered;
  final List<FoodItemData> foodItems;
  bool isAccepted;
  bool isDeclined;

  DeliveryOrderData({
    required this.deliveryId,
    required this.orderTime,
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.earningAmount,
    required this.status,
    this.assignedRiderId,
    required this.isDelivered,
    required this.foodItems,
    this.isAccepted = false,
    this.isDeclined = false,
  });

  factory DeliveryOrderData.fromMap(Map<String, dynamic> map, String docId) {
    final String deliveryId = map['deliveryId'] as String? ?? '';

    final String orderTime = map['orderTime'] as String? ?? '';

    // Vendor Location (Pickup)
    final String pickupLocation = map['location'] as String? ?? '';

    // Customer Address (Drop Off)
    final String dropOffLocation = map['deliveryAddress'] as String? ?? '';

    final String? assignedRiderId = map['assignedRiderId'] as String?;

    // Rider Earning Rule: (10% of totalPrice) + deliveryFee
    final double totalPrice = (map['totalPrice'] as num?)?.toDouble() ?? 0.0;
    final double deliveryFee = (map['deliveryFee'] as num?)?.toDouble() ?? 0.0;

    double calculatedEarningNum = (totalPrice * 0.10) + deliveryFee;

    String finalEarning = "";
    if (calculatedEarningNum > 0) {
      finalEarning = "RM ${calculatedEarningNum.toStringAsFixed(2)}";
    } else {
      finalEarning = map['earningAmount'] as String? ?? "Unknown Amount";
    }

    final String status = map['status'] as String? ?? 'pending';
    final bool isDelivered = map['isDelivered'] as bool? ?? (status == 'delivered');
    final bool isAccepted = (status == 'accepted' ||
        status == 'picked_up' ||
        status == 'vendor_qr_scanned' ||
        map['isAccepted'] == true);

    // Smartly parse orderItems string (e.g. "2x Big Mac, 1x French Fries") into individual items
    List<FoodItemData> foodItems = [];
    if (map['foodItems'] is List) {
      foodItems = (map['foodItems'] as List<dynamic>)
          .map((item) => FoodItemData.fromMap(item as Map<String, dynamic>))
          .toList();
    } else if (map['orderItems'] is String &&
        (map['orderItems'] as String).isNotEmpty) {
      final String rawItemsStr = map['orderItems'] as String;
      final List<String> itemParts = rawItemsStr.split(',');

      foodItems = itemParts.map((part) {
        final trimmed = part.trim();
        final match = RegExp(r'^(\d+)\s*x?\s*(.+)').firstMatch(trimmed);
        if (match != null) {
          final int qty = int.tryParse(match.group(1)!) ?? 1;
          final String itemName = match.group(2)!.trim();
          return FoodItemData(
            quantity: qty,
            name: itemName,
            price: '',
          );
        }
        return FoodItemData(
          quantity: 0,
          name: trimmed,
          price: '',
        );
      }).toList();
    }

    return DeliveryOrderData(
      deliveryId: deliveryId,
      orderTime: orderTime,
      pickupLocation: pickupLocation,
      dropOffLocation: dropOffLocation,
      earningAmount: finalEarning,
      status: status,
      assignedRiderId: assignedRiderId,
      isDelivered: isDelivered,
      foodItems: foodItems,
      isAccepted: isAccepted,
      isDeclined: map['isDeclined'] as bool? ?? (status == 'declined'),
    );
  }
}
