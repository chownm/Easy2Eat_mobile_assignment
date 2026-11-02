import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/cart_item_model.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:easy2eat/services/cart/cart_service.dart';

class ItemCustomizationSheet extends StatefulWidget {
  final MerchantModel merchant;

  const ItemCustomizationSheet({
    super.key,
    required this.merchant,
  });

  @override
  State<ItemCustomizationSheet> createState() => _ItemCustomizationSheetState();
}

class _ItemCustomizationSheetState extends State<ItemCustomizationSheet> {
  int _quantity = 1;
  final TextEditingController _itemInstructionsController =
    TextEditingController();
  final Set<String> _selectedItemTags = <String>{};

  @override
  void dispose() {
    _itemInstructionsController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedItemTags.contains(tag)) {
        _selectedItemTags.remove(tag);
      } else {
        _selectedItemTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double unitPrice = widget.merchant.unitPrice;
    final double totalPrice = unitPrice * _quantity;

    return Container(
      decoration: const BoxDecoration(
        color: ThemesColors.appSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Grab Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Item Title & Subtitle
            Text(
              widget.merchant.title,
              style: const TextStyle(
                color: ThemesColors.darkCharcoal,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.merchant.dualLangSubtitle,
              style: TextStyle(
                color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Stock: ${widget.merchant.dailyPortionsRemaining} portions left today',
              style: const TextStyle(
                color: ThemesColors.freshGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Divider(height: 28),

            // Portion Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Quantity',
                  style: TextStyle(
                    color: ThemesColors.darkCharcoal,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: ThemesColors.darkCharcoal.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                      ThemesColors.darkCharcoal.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.remove, size: 16),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed:
                        _quantity < widget.merchant.dailyPortionsRemaining
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Dietary Quick Tags
            const Text(
              'Dish Modifications (Specific to this item)',
              style: TextStyle(
                color: ThemesColors.darkCharcoal,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CartItemModel.dietaryQuickTags.map((String tag) {
                final bool isSelected = _selectedItemTags.contains(tag);
                return FilterChip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      color: isSelected
                          ? ThemesColors.appSurface
                          : ThemesColors.darkCharcoal,
                      fontSize: 12,
                      fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  showCheckmark: false,
                  backgroundColor: ThemesColors.appSurface,
                  selectedColor: ThemesColors.darkCharcoal,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? ThemesColors.darkCharcoal
                          : ThemesColors.darkCharcoal.withValues(alpha: 0.25),
                    ),
                  ),
                  onSelected: (_) => _toggleTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Custom Note Input
            TextField(
              controller: _itemInstructionsController,
              decoration: InputDecoration(
                hintText: 'Special kitchen instructions (e.g. less sauce)...',
                hintStyle: TextStyle(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
                filled: true,
                fillColor:
                ThemesColors.darkCharcoal.withValues(alpha: 0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Add to Cart Action
            ElevatedButton(
              onPressed: () {
                final customNote = _itemInstructionsController.text.trim();
                final List<String> tags = List.from(_selectedItemTags);
                if (customNote.isNotEmpty) tags.add(customNote);
                final String fullTag =
                tags.isNotEmpty ? tags.join(' • ') : 'Standard prep';

                // Add to persistent shared cart state
                CartService.addItem(
                  CartItemModel(
                    id: widget.merchant.id,
                    merchantId: 'VENDOR-001',
                    merchantName: widget.merchant.hubRouteLabel.isNotEmpty
                        ? widget.merchant.hubRouteLabel
                        : 'Campus Cafeteria',
                    title: widget.merchant.title,
                    dualLangSubtitle: widget.merchant.dualLangSubtitle,
                    unitPrice: unitPrice,
                    quantity: _quantity,
                    customizationTag: fullTag,
                    dailyPortionsRemaining:
                      widget.merchant.dailyPortionsRemaining,
                  ),
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: ThemesColors.freshGreen,
                    content: Text(
                        'Added $_quantity "${widget.merchant.title}" to Cart!'
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: ThemesColors.brandOrange,
                foregroundColor: ThemesColors.appSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Add to Cart • RM ${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
