import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class OrderDetail extends StatefulWidget {
  final int itemCount;

  const OrderDetail({
    super.key,
    this.itemCount = 1,
  });

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
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
    return Scrollbar(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: widget.itemCount, // Controlled dynamically via widget.itemCount
        itemBuilder: (context, index) {
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
                    Text(
                      "Delivery #${(index + 1).toString().padLeft(4, '0')}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ThemesColors.darkCharcoal,
                      ),
                    ),
                    // Timer Icon & Text
                    Row(
                      children: [
                        const Icon(
                          Icons.timer_outlined,
                          size: 20,
                          color: ThemesColors.darkCharcoal,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '04:45',
                          style: TextStyle(
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

                // Inner Card with FIXED height & scrollable food details list
                Container(
                  width: double.infinity,
                  height: 125, // Fixed height so it stays consistent
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Scrollbar(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        foodDetailRow(1, "Pizza", "\$10.00"),
                        const Divider(height: 12, thickness: 0.5),
                        foodDetailRow(2, "Burger", "\$15.00"),
                        const Divider(height: 12, thickness: 0.5),
                        foodDetailRow(1, "Spaghetti", "\$12.00"),
                        const Divider(height: 12, thickness: 0.5),
                        foodDetailRow(2, "French Fries", "\$5.00"),
                        const Divider(height: 12, thickness: 0.5),
                        foodDetailRow(1, "Coca-Cola", "\$2.50"),
                      ],
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
                    const Expanded(
                      child: Text(
                        "Pickup: Kuala Lumpur",
                        style: TextStyle(
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
                    const Expanded(
                      child: Text(
                        "Drop Off: Jalan Tun",
                        style: TextStyle(
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
                  children: const [
                    Text(
                      "Earning:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ThemesColors.darkCharcoal,
                      ),
                    ),
                    Text(
                      "RM100",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: ThemesColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Accept and Decline Button
                Row(
                  children: [
                    // Decline Button
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
                          // Handle decline button press
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

                    // Accept Button
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
                          // Handle accept button press
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
            ),
          );
        },
      ),
    );
  }
}

// Alias for backwards compatibility
typedef orderDetail = OrderDetail;
