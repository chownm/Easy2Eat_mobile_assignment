import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/home/widgets/category_filter_bar.dart';
import 'package:easy2eat/features/customer/home/widgets/feed_section_header.dart';
import 'package:easy2eat/features/customer/home/widgets/home_search_box.dart';
import 'package:easy2eat/features/customer/home/widgets/merchant_feed_card.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.appSurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Top Bar
            const SharedCustomerTopBar(
              title: 'Easy2Eat',
              subtitle: 'Hyper-Local <1km Unstacked Dispatch Active',
              showPulseIndicator: true,
              showProfileButton: true,
            ),

            const SizedBox(height: 14),

            // 2. Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomerSearchHeaderWidget(
                hintText: 'Search dishes (e.g. Chicken Chop)...',
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim().toLowerCase());
                },
              ),
            ),

            const SizedBox(height: 14),

            // 3. Category Filter Bar
            CustomerCategoryFilterStrip(
              categories: CustomerMerchantFeedCard.categoryFilters,
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (index) {
                setState(() => _selectedCategoryIndex = index);
              },
            ),

            const SizedBox(height: 16),

            // 4. Stream Live Items directly from Vendor's 'inventory' collection
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('inventory')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ThemesColors.brandOrange,
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No menu items published yet.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  // Deserialization
                  List<MerchantModel> items = docs
                      .map((doc) => MerchantModel.fromFirestore(doc))
                      .toList();

                  // Apply Category Filter
                  final selectedCategory =
                  CustomerMerchantFeedCard.categoryFilters[_selectedCategoryIndex];
                  if (selectedCategory == 'Portions In Stock') {
                    items = items.where((e) => e.isInStock).toList();
                  } else if (selectedCategory == '< 1km Direct') {
                    items = items.where((e) => e.distanceKm <= 1.0).toList();
                  }

                  // Apply Live Search Filter
                  if (_searchQuery.isNotEmpty) {
                    items = items.where((e) {
                      return e.title.toLowerCase().contains(_searchQuery) ||
                          e.dualLangSubtitle.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CustomerFeedSectionHeader(
                          sectionTitle: 'Available Dishes',
                          merchantCount: items.length,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: items.isEmpty
                            ? Center(
                          child: Text(
                            'No dishes matching "$_searchQuery"',
                            style: TextStyle(
                              color: ThemesColors.darkCharcoal
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        )
                            : ListView.separated(
                          padding:
                          const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: items.length,
                          separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return CustomerMerchantFeedCard(
                              merchant: items[index],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}