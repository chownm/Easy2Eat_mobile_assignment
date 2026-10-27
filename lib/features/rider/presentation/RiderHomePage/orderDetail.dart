import 'package:flutter/material.dart';
import '../../../../core/constants/active_delivery.dart';
import '../../../../core/routing/RiderRouting.dart';
import '../../../../core/theme/theme.dart';

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
  final String timer;
  final String pickupLocation;
  final String dropOffLocation;
  final String earningAmount;
  final List<FoodItemData> foodItems;
  bool isAccepted;
  bool isDeclined;

  DeliveryOrderData({
    required this.deliveryId,
    required this.timer,
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.earningAmount,
    required this.foodItems,
    this.isAccepted = false,
    this.isDeclined = false,
  });

  factory DeliveryOrderData.fromMap(Map<String, dynamic> map, String docId) {
    return DeliveryOrderData(
      deliveryId: docId,
      timer: map['timer'] as String? ?? '04:45',
      pickupLocation: map['pickupLocation'] as String? ?? 'Pickup: Kuala Lumpur',
      dropOffLocation: map['dropOffLocation'] as String? ?? 'Drop Off: Jalan Tun',
      earningAmount: map['earningAmount'] as String? ?? 'RM100',
      foodItems: (map['foodItems'] as List<dynamic>?)
              ?.map((item) => FoodItemData.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      isAccepted: map['isAccepted'] as bool? ?? false,
      isDeclined: map['isDeclined'] as bool? ?? false,
    );
  }
}

class OrderDetail extends StatefulWidget {
  final List<DeliveryOrderData>? orders;

  const OrderDetail({
    super.key,
    this.orders,
  });

  @override
  State<OrderDetail> createState() => OrderDetailState();
}

class OrderDetailState extends State<OrderDetail> {
  // Static sets so accepted/declined state persists across page navigation!
  static final Set<String> _globalAcceptedOrders = {};
  static final Set<String> _globalDeclinedOrders = {};

  void resetOrders() {
    setState(() {
      _globalAcceptedOrders.clear();
      _globalDeclinedOrders.clear();
    });
  }

  /// Default mock orders if database list is null or empty
  List<DeliveryOrderData> get _effectiveOrders {
    if (widget.orders != null && widget.orders!.isNotEmpty) {
      return widget.orders!;
    }
    return [
      DeliveryOrderData(
        deliveryId: "Delivery #0001",
        timer: "04:45",
        pickupLocation: "Pickup: Kuala Lumpur",
        dropOffLocation: "Drop Off: Jalan Tun",
        earningAmount: "RM100",
        foodItems: const [
          FoodItemData(quantity: 1, name: "Pizza", price: "\$10.00"),
          FoodItemData(quantity: 2, name: "Burger", price: "\$15.00"),
          FoodItemData(quantity: 1, name: "Spaghetti", price: "\$12.00"),
          FoodItemData(quantity: 2, name: "French Fries", price: "\$5.00"),
          FoodItemData(quantity: 1, name: "Coca-Cola", price: "\$2.50"),
        ],
      ),
    ];
  }

  /// Individual food item row
  Widget foodDetailRow(int quantity, String foodName, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "${quantity}x",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemesColors.darkCharcoal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              foodName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ThemesColors.darkCharcoal,
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ThemesColors.darkCharcoal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = _effectiveOrders
        .where((order) =>
            !_globalDeclinedOrders.contains(order.deliveryId) && !order.isDeclined)
        .toList();

    // Show empty state when all orders are declined/removed
    if (activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              "No incoming orders",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: resetOrders,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh Orders"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemesColors.darkCharcoal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scrollbar(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: activeOrders.length,
        itemBuilder: (context, index) {
          final order = activeOrders[index];
          final String deliveryId = order.deliveryId;
          final bool isAccepted =
              _globalAcceptedOrders.contains(deliveryId) || order.isAccepted;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Delivery ID & Estimate Timer Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          deliveryId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ThemesColors.darkCharcoal,
                          ),
                        ),
                        if (isAccepted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: ThemesColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "ACCEPTED",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: ThemesColors.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 20,
                          color: ThemesColors.darkCharcoal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.timer,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ThemesColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Inner Card with FIXED height & dynamic food details list
                Container(
                  width: double.infinity,
                  height: 125,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Scrollbar(
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: order.foodItems.length,
                      separatorBuilder: (context, i) =>
                          const Divider(height: 12, thickness: 0.5),
                      itemBuilder: (context, itemIndex) {
                        final item = order.foodItems[itemIndex];
                        return foodDetailRow(
                          item.quantity,
                          item.name,
                          item.price,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Pickup Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.storefront,
                      size: 18,
                      color: ThemesColors.darkCharcoal,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.pickupLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ThemesColors.darkCharcoal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Drop Off Location
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: ThemesColors.darkCharcoal,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.dropOffLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ThemesColors.darkCharcoal,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1),

                // Earning Money Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Earning:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemesColors.darkCharcoal,
                      ),
                    ),
                    Text(
                      order.earningAmount,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemesColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Show View Route Button if Accepted, else show Decline and Accept
                if (isAccepted) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemesColors.brandOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Set primary active delivery number!
                        ActiveDeliveryState.currentDeliveryNumber = deliveryId;

                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.riderMaps,
                          arguments: deliveryId,
                        );
                      },
                      icon: const Icon(
                        Icons.alt_route_rounded,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "View Route",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    children: [
                      // Decline Button -> Hides delivery
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: ThemesColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _globalDeclinedOrders.add(deliveryId);
                              order.isDeclined = true;
                            });
                          },
                          child: const Text(
                            "Decline",
                            style: TextStyle(
                              fontSize: 16,
                              color: ThemesColors.darkCharcoal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Accept Button -> Shows "View Route"
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: ThemesColors.darkCharcoal,
                            foregroundColor: ThemesColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _globalAcceptedOrders.add(deliveryId);
                              order.isAccepted = true;
                              ActiveDeliveryState.currentDeliveryNumber = deliveryId;
                            });
                          },
                          child: const Text(
                            "Accept",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// Alias for backwards compatibility
typedef orderDetail = OrderDetail;
