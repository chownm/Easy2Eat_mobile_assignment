import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/cart_checkout/checkout_payment_screen.dart';
import 'package:easy2eat/features/customer/cart_checkout/widgets/cart_item_tile.dart';
import 'package:easy2eat/features/customer/cart_checkout/widgets/checkout_summary_card.dart';
import 'package:easy2eat/features/customer/models/cart_item_model.dart';
import 'package:easy2eat/services/cart/cart_service.dart';
import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';

class CustomerCartCheckoutScreen extends StatelessWidget {
  const CustomerCartCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.appSurface,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<List<CartItemModel>>(
          valueListenable: CartService.cartNotifier,
          builder: (context, cartItems, _) {
            final double subTotal = CartItemModel.calculateSubtotal(cartItems);
            final double deliveryFee =
            cartItems.isEmpty ? 0.0 : CartItemModel.directUnstackedDeliveryFee;
            final double packagingFee =
            cartItems.isEmpty ? 0.0 : CartItemModel.platformPackagingFee;
            final double totalAmount =
            cartItems.isEmpty ? 0.0 : subTotal + deliveryFee + packagingFee;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SharedCustomerTopBar(
                  title: 'Shopping Cart',
                  showBackButton: false,
                  showProfileButton: false,
                ),
                Expanded(
                  child: cartItems.isEmpty
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
                        const SizedBox(height: 4),
                        Text(
                          'Add dishes from the home feed to check out.',
                          style: TextStyle(
                            color: ThemesColors.darkCharcoal
                                .withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final CartItemModel item = cartItems[index];
                      return CustomerCartItemTile(
                        item: item,
                        onIncrement: () =>
                            CartService.incrementQuantity(index),
                        onDecrement: () {
                          if (item.quantity > 1) {
                            CartService.decrementQuantity(index);
                          } else {
                            _showRemoveItemDialog(context, index, item.title);
                          }
                        },
                      );
                    },
                  ),
                ),
                if (cartItems.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: ThemesColors.appSurface,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: ThemesColors.darkCharcoal
                              .withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                      border: Border(
                        top: BorderSide(
                          color: ThemesColors.darkCharcoal
                              .withValues(alpha: 0.1),
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
                                  cartItems: cartItems,
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
            );
          },
        ),
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, int index, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemesColors.appSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Remove Item',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text('Remove "$title" from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              CartService.removeItem(index);
            },
            child: const Text('Remove',
                style: TextStyle(
                    color: ThemesColors.brandOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}