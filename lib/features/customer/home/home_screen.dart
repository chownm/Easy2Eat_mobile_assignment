import 'package:easy2eat/core/enum/user_role.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';
import 'package:easy2eat/features/customer/home/widgets/home_search_box.dart';
import 'package:easy2eat/features/customer/home/widgets/category_filter_bar.dart';
import 'package:easy2eat/features/customer/home/widgets/feed_section_header.dart';
import 'package:easy2eat/features/customer/home/widgets/merchant_feed_card.dart';
import 'package:easy2eat/shared/widgets/shared_navigation_bar.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.appSurface,
      body: SafeArea(
          bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Top Bar
        const SharedCustomerTopBar(
          title: 'Easy2Eat • C180 / Traders Sq',
          subtitle: 'Hyper-Local <1km Unstacked Dispatch Active',
          showPulseIndicator: true,
          showProfileButton: true,
        ),

        const SizedBox(height: 14),

          // Search Bar
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CustomerSearchHeaderWidget(
                hintText: 'Search2Eat',
            ),
          ),

          const SizedBox(height: 14),

          // Scrollable Category Bar
          const CustomerCategoryFilterStrip(
              categories: CustomerMerchantFeedCard.categoryFilters,
              selectedIndex: 0,
          ),

          const SizedBox(height: 16),

          // Feed Section Header
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomerFeedSectionHeader(
                sectionTitle: 'Nearby Merchants',
                merchantCount: CustomerMerchantFeedCard.merchantFeed.length,
            ),
          ),

          const SizedBox(height: 12),

          // Merchant Infinite Feed
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              physics: const BouncingScrollPhysics(),
              itemCount: CustomerMerchantFeedCard.merchantFeed.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 16),
              itemBuilder: (BuildContext context, int index) {
                final StaticMerchantModel merchant = CustomerMerchantFeedCard.merchantFeed[index];
                return CustomerMerchantFeedCard(merchant: merchant);
              }
            ),
          )
      ],),
      ),
    );
  }
}