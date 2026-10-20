import 'package:flutter/material.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:easy2eat/core/theme/theme.dart';

// Component 2: Search Input Bar
class CustomerSearchHeaderWidget extends StatelessWidget {
  final String hintText;

  const CustomerSearchHeaderWidget({
    super.key,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      decoration: BoxDecoration(
        color: ThemesColors.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: TextField(
        readOnly: true, // Static UI Mode
        style: const TextStyle(
          color: ThemesColors.darkCharcoal,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: ThemesColors.darkCharcoal.withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: ThemesColors.darkCharcoal,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}