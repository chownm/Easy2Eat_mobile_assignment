import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';

class CustomerCourierContactCard extends StatelessWidget {
  final CourierProfileModel courier;
  final VoidCallback onChatWithRider;

  const CustomerCourierContactCard({
    super.key,
    required this.courier,
    required this.onChatWithRider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemesColors.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Courier Information Row
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: ThemesColors.darkCharcoal,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.two_wheeler_rounded,
                  color: ThemesColors.appSurface,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      courier.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ThemesColors.darkCharcoal,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${courier.plateNumber} (${courier.vehicleType}) • Direct Fleet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // High-Contrast Direct Chat Action Button
          ElevatedButton.icon(
            onPressed: onChatWithRider,
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 16,
              color: ThemesColors.appSurface,
            ),
            label: const Text(
              'Chat with Rider',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: ThemesColors.appSurface,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemesColors.darkCharcoal,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 11),
            ),
          ),
        ],
      ),
    );
  }
}