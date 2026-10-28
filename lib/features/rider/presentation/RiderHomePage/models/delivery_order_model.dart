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
      price: map['price'] as String? ?? '\$0.00',
    );
  }
}

/// Database Model for Delivery Order
class DeliveryOrderData {
  final String deliveryId;
  final String orderTime;
  final String pickupLocation;
  final String dropOffLocation;
  final String earningAmount;
  final String status;
  final bool isDelivered;
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
    required this.isDelivered,
    required this.foodItems,
    this.isAccepted = false,
    this.isDeclined = false,
  });

  factory DeliveryOrderData.fromMap(Map<String, dynamic> map, String docId) {
    String formattedTime = "12:45 PM, 26 Oct";
    final rawTime = map['orderTime'] ?? map['order_time'] ?? map['timestamp'] ?? map['timer'];
    if (rawTime != null) {
      formattedTime = rawTime.toString();
    }

    return DeliveryOrderData(
      deliveryId: docId,
      orderTime: formattedTime,
      pickupLocation: map['pickupLocation'] as String? ?? 'Pickup: Kuala Lumpur',
      dropOffLocation: map['dropOffLocation'] as String? ?? 'Drop Off: Jalan Tun',
      earningAmount: map['earningAmount'] as String? ?? 'RM100',
      status: map['status'] as String? ?? 'pending',
      isDelivered: map['isDelivered'] as bool? ?? false,
      foodItems: (map['foodItems'] as List<dynamic>?)
              ?.map((item) => FoodItemData.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      isAccepted: map['isAccepted'] as bool? ?? false,
      isDeclined: map['isDeclined'] as bool? ?? false,
    );
  }
}
