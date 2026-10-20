import 'package:flutter/material.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:easy2eat/core/theme/theme.dart';

// Component 3: Scrollable Category Bar
class CustomerCategoryFilterStrip extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;

  const CustomerCategoryFilterStrip({
    super.key,
    required this.categories,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Scales height safely if user increase the font size in settings
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double adaptiveStripHeight = (38.0 * textScale).clamp(38.0, 54.0);

    return SizedBox(
      height: adaptiveStripHeight,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (BuildContext context, int index) =>
        const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final bool isSelected = index == selectedIndex;
          final String categoryLabel = categories[index];

          return Material(
            color: isSelected
                ? ThemesColors.darkCharcoal
                : ThemesColors.appSurface,
            shape: StadiumBorder(
              side: BorderSide(
                color: isSelected
                    ? ThemesColors.darkCharcoal
                    : ThemesColors.darkCharcoal.withValues(alpha: 0.2),
                width: 1.2,
              ),
            ),
            child: InkWell(
              onTap: () {
                // will dispatch category selection to customerHomeProvider
              },
              customBorder: const StadiumBorder(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Center(
                  child: Text(
                    categoryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? ThemesColors.appSurface
                          : ThemesColors.darkCharcoal,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}