import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/cart_item_model.dart';

// Widget 3: Dietary Note Box
class CustomerDietaryNoteBox extends StatelessWidget {
  final TextEditingController noteController;
  final List<String> availableQuickTags;
  final Set<String> selectedQuickTags;
  final ValueChanged<String> onTagToggled;

  const CustomerDietaryNoteBox ({
    super.key,
    required this.noteController,
    required this.availableQuickTags,
    required this.selectedQuickTags,
    required this.onTagToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemesColors.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header Row
          const Row(
            children: <Widget>[
              Icon(
                Icons.restaurant_rounded,
                size: 18,
                color: ThemesColors.brandOrange,
              ),
              SizedBox(width: 6),
              Text(
                'Dietary & Kitchen Instructions',
                style: TextStyle(
                  color: ThemesColors.darkCharcoal,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Feeds directly into the vendor high-contrast ticket',
            style: TextStyle(
              color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // Quick Preset Tag Selector Strip
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: availableQuickTags.map((String tag) {
              final bool isSelected = selectedQuickTags.contains(tag);
              return FilterChip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected
                          ? ThemesColors.appSurface
                          : ThemesColors.darkCharcoal,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  showCheckmark: true,
                  checkmarkColor: ThemesColors.brandOrange,
                  backgroundColor: ThemesColors.appSurface,
                  selectedColor: ThemesColors.darkCharcoal,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? ThemesColors.darkCharcoal
                          : ThemesColors.darkCharcoal.withValues(alpha: 0.22),
                    ),
                  ),
                  onSelected: (_) => onTagToggled(tag),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Freeform Text Input for Kitchen Notes
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: ThemesColors.darkCharcoal.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:ThemesColors.darkCharcoal.withValues(alpha: 0.16),
              ),
            ),
            child: TextField(
              controller: noteController,
              maxLines: 2,
              style: const TextStyle(
                color: ThemesColors.darkCharcoal,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText:
                  'Special instructions (e.g. Allergy alert, extra spicy)...',
                hintStyle: TextStyle(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}