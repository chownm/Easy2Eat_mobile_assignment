import 'package:flutter/material.dart';
import '../../../../../core/theme/theme.dart';
import '../models/delivery_order_model.dart';

class OrderCardItem extends StatelessWidget {
  final DeliveryOrderData order;
  final bool isAccepted;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onViewRoute;
  final VoidCallback onArrived;
  final List<FoodItemData> defaultFoodItems;

  const OrderCardItem({
    super.key,
    required this.order,
    required this.isAccepted,
    required this.isLoading,
    required this.onAccept,
    required this.onDecline,
    required this.onViewRoute,
    required this.onArrived,
    required this.defaultFoodItems,
  });

  Widget _foodDetailRow(int quantity, String foodName, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          if (quantity > 0) ...[
            Text(
              "${quantity}x",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ThemesColors.darkCharcoal,
              ),
            ),
            const SizedBox(width: 10),
          ],
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
          if (price.isNotEmpty && price != 'RM0.00' && !price.endsWith('RM 0.00'))
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
    final String deliveryId = order.deliveryId;
    final List<FoodItemData> foodList =
        order.foodItems.isNotEmpty ? order.foodItems : defaultFoodItems;

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
          // Delivery ID & Order Time Header
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
                    Icons.access_time_rounded,
                    size: 18,
                    color: ThemesColors.darkCharcoal,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.orderTime,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ThemesColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Food items list container
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
                itemCount: foodList.length,
                separatorBuilder: (context, i) =>
                    const Divider(height: 12, thickness: 0.5),
                itemBuilder: (context, itemIndex) {
                  final item = foodList[itemIndex];
                  return _foodDetailRow(
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
                  "Pick up: ${order.pickupLocation}",
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
                  "Drop off: ${order.dropOffLocation}",
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

          // Action Buttons
          if (isAccepted) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemesColors.brandOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onViewRoute,
                    icon: const Icon(Icons.alt_route_rounded, color: Colors.white),
                    label: const Text(
                      "View Route",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemesColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : onArrived,
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Arrived",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
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
                    onPressed: isLoading ? null : onDecline,
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: ThemesColors.error,
                            ),
                          )
                        : const Text(
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
                    onPressed: isLoading ? null : onAccept,
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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
  }
}
