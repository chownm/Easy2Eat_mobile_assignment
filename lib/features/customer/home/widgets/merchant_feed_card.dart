import 'package:flutter/material.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:easy2eat/core/theme/theme.dart';

// Component 5: Merchant Feed Card
class CustomerMerchantFeedCard extends StatelessWidget {
  final StaticMerchantModel merchant;

  const CustomerMerchantFeedCard({
    super.key,
    required this.merchant,
  });

  // Hardcoded category filter tags
  static const List<String> categoryFilters = <String>[
    'All Hub Stores',
    '< 1km Direct',
    'Nasi Lemak',
    'Hawker Wok',
    'Beverages',
    'Shift Pre-Order',
    'Dual-Language',
  ];

  // Hardcoded merchant feed records
  static const List<StaticMerchantModel> merchantFeed = <StaticMerchantModel> [
    StaticMerchantModel(
      id: 'merchant_v02_chagee',
      title: "CHAGEE - Trader Square",
      dualLangSubtitle: 'Chinese Milk Tea • 中国奶茶专卖店',
      categoryTag: 'Milk Tea',
      rating: 4.9,
      distanceKm: 1.1,
      hubRouteLabel: 'C180 ↔ Cheras Traders Square',
      executionCostAndEta: 'RM 8.50 • 10 mins • RM 1.50 Delivery',
      operationalTags: <String>[
        'Direct <1km',
        'Unstacked Route',
        'High-Contrast Ticket',
      ],
      dailyPortionsRemaining: 36,
      isDirectUnstackedEligible: true,
    ),
    StaticMerchantModel(
      id: 'merchant_v01_shinzushi',
      title: "Shin Zushi C180",
      dualLangSubtitle: 'Japanese Sushi • 日本寿司店',
      categoryTag: 'Sushi',
      rating: 4.8,
      distanceKm: 0.4,
      hubRouteLabel: 'C180 Commercial Hub',
      executionCostAndEta: 'RM 5.50 • 15 mins • RM 1.00 Delivery',
      operationalTags: <String>[
        'Direct <1km',
        '4-Stage Kitchen Tracker',
        'QR Verified Bag',
      ],
      dailyPortionsRemaining: 200,
      isDirectUnstackedEligible: true,
    ),
    StaticMerchantModel(
      id: 'merchant_v03_baiwei',
      title: "Bai Wei Mini Bowl 百味小碗菜",
      dualLangSubtitle: 'Chinese Cuisine • 中国食品',
      categoryTag: 'Chinese Food',
      rating: 4.7,
      distanceKm: 1.0,
      hubRouteLabel: 'C180 ↔ Cheras Traders Square',
      executionCostAndEta: 'RM 8.50 • 8 mins • RM 1.50 Delivery',
      operationalTags: <String>[
        'Direct <1km',
        'Live Dishes Stock',
        'Shift Pre-Order',
      ],
      dailyPortionsRemaining: 24,
      isDirectUnstackedEligible: true,
    ),
    StaticMerchantModel(
      id: 'merchant_v04_hanambbq',
      title: 'Hanam BBQ - Cheras C180',
      dualLangSubtitle: 'Korean BBQ • 韩国烧烤',
      categoryTag: 'KoreanBBQ',
      rating: 4.6,
      distanceKm: 0.5,
      hubRouteLabel: 'C180 Commercial Hub',
      executionCostAndEta: 'RM 5.50 • 14 mins • RM 1.20 Delivery',
      operationalTags: <String>[
        'Direct <1km',
        'Hot food',
        'Fast food',
      ],
      dailyPortionsRemaining: 12,
      isDirectUnstackedEligible: true,
    ),
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
            // Restaurant Imagery Bounding Box
            AspectRatio(
              aspectRatio: 16 / 8,
              child: Container(
                color: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 36,
                    color: ThemesColors.darkCharcoal.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),

            // Card Metadata and Action Body
            Padding(padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Row 1: Restaurant Title + Review Star Counter
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
                                color: ThemesColors.darkCharcoal.withValues(
                                    alpha: 0.65
                                ),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ) ,
                      ),
                      const SizedBox(width: 10),

                      // Review Star Counter Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: ThemesColors.appSurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ThemesColors.darkCharcoal.withValues(
                              alpha: 0.2,
                            ),
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
                      )
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Row 2: Distance, Hub Corridor and Execution Cost
                  Text(
                    '${merchant.hubRouteLabel} • ${merchant.executionCostAndEta}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ThemesColors.darkCharcoal.withValues(
                          alpha: 0.75
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Row 3: Operational and Dietary Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: merchant.operationalTags.map((String tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ThemesColors.appSurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: ThemesColors.darkCharcoal.withValues(
                              alpha: 0.22,
                            ),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: ThemesColors.darkCharcoal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // Row 4: Two side by side Action Button
                  Row(
                    children: <Widget>[
                      // Button 1: Customize
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Hook for item customization
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 42),
                            foregroundColor: ThemesColors.darkCharcoal,
                            side: BorderSide(
                              color: ThemesColors.darkCharcoal.withValues(
                                  alpha: 0.25
                              ),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Customize',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Button 2: Add to Cart
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Hook for adding item to Cart
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 42),
                            elevation: 0,
                            backgroundColor: ThemesColors.brandOrange,
                            foregroundColor:
                            ThemesColors.appSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Add to Cart',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}