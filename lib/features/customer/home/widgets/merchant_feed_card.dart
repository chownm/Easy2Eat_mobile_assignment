import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/cart_checkout/widgets/item_customization_sheet.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';

class CustomerMerchantFeedCard extends StatelessWidget {
  final MerchantModel merchant;

  const CustomerMerchantFeedCard({
    super.key,
    required this.merchant,
  });

  static const List<String> categoryFilters = <String>[
    'All Hub Dishes',
    '< 1km Direct',
    'Main Dishes',
    'Beverages',
    'Portions In Stock',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemesColors.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Image Box: Uses vendor's imageURL if populated, otherwise stylized dish placeholder
            AspectRatio(
              aspectRatio: 16 / 8,
              child: merchant.imageUrl.isNotEmpty
                  ? Image.network(
                merchant.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                  child: const Icon(Icons.fastfood_outlined,
                      size: 36, color: Colors.grey),
                ),
              )
                  : Container(
                color: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    size: 38,
                    color: ThemesColors.brandOrange.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Title + Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              merchant.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ThemesColors.darkCharcoal,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              merchant.dualLangSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ThemesColors.darkCharcoal
                                    .withValues(alpha: 0.65),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: ThemesColors.appSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ThemesColors.darkCharcoal
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.star_rounded,
                              color: ThemesColors.promoYellow,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              merchant.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: ThemesColors.darkCharcoal,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${merchant.hubRouteLabel} • ${merchant.executionCostAndEta}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                      ThemesColors.darkCharcoal.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: merchant.operationalTags.map((String tag) {
                      final bool isSoldOutTag = tag == 'Sold Out';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSoldOutTag
                              ? Colors.red.shade50
                              : ThemesColors.appSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSoldOutTag
                                ? Colors.red.shade200
                                : ThemesColors.darkCharcoal
                                .withValues(alpha: 0.22),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSoldOutTag
                                ? Colors.red.shade800
                                : ThemesColors.darkCharcoal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Add to Cart Action
                  ElevatedButton.icon(
                    onPressed: merchant.isInStock
                        ? () {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (BuildContext sheetContext) {
                          return ItemCustomizationSheet(merchant: merchant);
                        },
                      );
                    }
                        : null,
                    icon: Icon(
                      merchant.isInStock
                          ? Icons.add_shopping_cart_rounded
                          : Icons.block_rounded,
                      size: 18,
                    ),
                    label: Text(
                      merchant.isInStock
                          ? 'Add to Cart • RM ${merchant.unitPrice.toStringAsFixed(2)}'
                          : 'Currently Sold Out',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      elevation: 0,
                      backgroundColor: ThemesColors.brandOrange,
                      foregroundColor: ThemesColors.appSurface,
                      disabledBackgroundColor:
                      ThemesColors.darkCharcoal.withValues(alpha: 0.1),
                      disabledForegroundColor:
                      ThemesColors.darkCharcoal.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}