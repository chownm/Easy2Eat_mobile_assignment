import 'package:flutter/material.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:easy2eat/core/theme/theme.dart';

// Component 4: Feed Section Header
class CustomerFeedSectionHeader extends StatelessWidget {
  final String sectionTitle;
  final int merchantCount;

  const CustomerFeedSectionHeader({
    super.key,
    required this.sectionTitle,
    required this.merchantCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Flexible(
          child: Text(
            sectionTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThemesColors.darkCharcoal,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: ThemesColors.darkCharcoal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$merchantCount',
            style: const TextStyle(
              color: ThemesColors.darkCharcoal,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        )
      ],
    );
  }
}