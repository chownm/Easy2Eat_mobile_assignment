import 'package:easy2eat/core/enum/user_role.dart';
import 'package:easy2eat/features/customer/models/merchant_model.dart';
import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/cart_item_model.dart';
import 'package:easy2eat/features/customer/cart_checkout/widgets/cart_item_tile.dart';
import 'package:easy2eat/features/customer/cart_checkout/widgets/checkout_summary_card.dart';
import 'package:easy2eat/features/customer/cart_checkout/widgets/delivery_pin_card.dart';
import 'package:easy2eat/features/customer/cart_checkout/widgets/dietary_note_box.dart';
import 'package:easy2eat/shared/widgets/shared_navigation_bar.dart';
import 'package:easy2eat/features/customer/cart_checkout/checkout_payment_screen.dart';

// Customer Cart Checkout screen
class CustomerCartCheckoutScreen extends StatefulWidget {
  const CustomerCartCheckoutScreen({super.key});

  @override
  State<CustomerCartCheckoutScreen> createState() =>
      _CustomerCartCheckoutScreenState();
}

class _CustomerCartCheckoutScreenState extends State<CustomerCartCheckoutScreen> {
  // Local state but will connect to Riverpod later
  late List<CartItemModel> _cartItems;

  @override
  void initState() {
    super.initState();
    _cartItems = List<CartItemModel>.from(CartItemModel.mockCartItems);
  }

  void _incrementQuantity(int index) {
    setState(() {
      final CartItemModel item = _cartItems[index];
      if (item.quantity < item.dailyPortionsRemaining) {
        _cartItems[index] = item.copyWith(quantity: item.quantity + 1);
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                'Max available portions reached for ${item.title}',
              ),
          ),
        );
      }
    });
  }

  Future<void> _decrementQuantity(int index) async {
    final CartItemModel item = _cartItems[index];

    if (item.quantity > 1) {
      setState(() {
        _cartItems[index] = item.copyWith(quantity: item.quantity - 1);
      });
      return;
    }

    final bool? confirmRemove = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: ThemesColors.appSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: ThemesColors.darkCharcoal.withValues(alpha: 0.12),
            ),
          ),
          title: const Text(
            'Remove Item',
            style: TextStyle(
              color: ThemesColors.darkCharcoal,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Remove "${item.title}" from your cart?',
            style: TextStyle(
              color: ThemesColors.darkCharcoal.withValues(alpha: 0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: ThemesColors.darkCharcoal,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Remove',
                style: TextStyle(
                  color: ThemesColors.brandOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirmRemove == true) {
      setState(() {
        _cartItems.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double subTotal = CartItemModel.calculateSubtotal(_cartItems);
    final double deliveryFee = CartItemModel.directUnstackedDeliveryFee;
    const double packagingFee = CartItemModel.platformPackagingFee;
    final double totalAmount =
    _cartItems.isEmpty ? 0.0 : subTotal + deliveryFee + packagingFee;

    return Scaffold(
      backgroundColor: ThemesColors.appSurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // 1. Top Bar
            const SharedCustomerTopBar(
              title: 'Shopping Cart',
              showBackButton: false,
              showProfileButton: false,
            ),

            // 2. Itemized Cart Tiles
            Expanded(
              child: _cartItems.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 64,
                      color: ThemesColors.darkCharcoal
                          .withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        color: ThemesColors.darkCharcoal,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                physics: const BouncingScrollPhysics(),
                itemCount: _cartItems.length,
                separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final CartItemModel item = _cartItems[index];
                  return CustomerCartItemTile(
                    item: item,
                    onIncrement: () => _incrementQuantity(index),
                    onDecrement: () => _decrementQuantity(index),
                  );
                },
              ),
            ),

            // 3. Cost Breakdown Matrix (Always visible)
            if (_cartItems.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: ThemesColors.appSurface,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color:
                      ThemesColors.darkCharcoal.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: ThemesColors.darkCharcoal.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: CustomerCheckoutSummaryCard(
                  subTotal: subTotal,
                  deliveryFee: deliveryFee,
                  packagingFee: packagingFee,
                  totalAmount: totalAmount,
                  buttonText: 'Proceed to Checkout',
                  onConfirmOrder: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            CustomerCheckoutPaymentScreen(
                              cartItems: _cartItems,
                              subTotal: subTotal,
                              deliveryFee: deliveryFee,
                              packagingFee: packagingFee,
                              totalAmount: totalAmount,
                            ),
                      ),
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