import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/cart_item_model.dart';
import 'package:easy2eat/features/customer/cart_checkout/widgets/delivery_pin_card.dart';
import 'package:easy2eat/features/customer/tracking/tracking_screen.dart';
import 'package:easy2eat/features/customer/customer_shell_screen.dart';

enum PaymentMethod {
  tngEWallet,
  onlineBankingFpx,
  cashOnDelivery,
}

class CustomerCheckoutPaymentScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double subTotal;
  final double deliveryFee;
  final double packagingFee;
  final double totalAmount;

  const CustomerCheckoutPaymentScreen({
    super.key,
    required this.cartItems,
    required this.subTotal,
    required this.deliveryFee,
    required this.packagingFee,
    required this.totalAmount,
  });

  @override
  State<CustomerCheckoutPaymentScreen> createState() =>
      _CustomerCheckoutPaymentScreenState();
}

class _CustomerCheckoutPaymentScreenState
    extends State<CustomerCheckoutPaymentScreen> {
  DeliveryTimingMode _selectedTimingMode = DeliveryTimingMode.immediateDirect;
  PaymentMethod _selectedPayment = PaymentMethod.tngEWallet;
  bool _isProcessing = false;

  Future<void> _placeOrder() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Generate a clean Order ID
      final String orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}';

      // 2. Format cart items into the single String expected by the Vendor's schema
      final String orderItemsString = widget.cartItems
          .map((item) => '${item.quantity}x ${item.title} (${item.customizationTag})')
          .join('\n');

      // 3. Build the payload exactly matching the Vendor's OrderModel
      final Map<String, dynamic> orderPayload = {
        'orderId': orderId,    // For Tracking/Rider sync
        'orderID': orderId,    // Preserved for Vendor schema
        'qrID': orderId,
        'customerName': 'Joel Ira',
        'customerPhone': '+60 12-892 4118',
        'orderItems': orderItemsString,
        'totalPrice': widget.totalAmount,
        'status': 'pending',
        'stage': 'preparing',  // Stage 1 initial state
        'isPaused': false,
        'pauseReason': '',
        'statusDescription': 'Order received. Kitchen has queued your ticket for prep.',
        'timeAgo': 'Just now',
        'location': CartItemModel.mockDropOffPin.microPinLandmark,
        'createdAt': DateTime.now().toIso8601String(),
        'assignedRiderId': null,
        'riderName': null,
        'riderPhone': null,
        'isPickedUp': false,
        'pickedUpAt': null,
      };

      // 4. Execute the Firestore write
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderPayload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: ThemesColors.freshGreen,
          content: Text('Order placed successfully!'),
        ),
      );

      // 5. Route to Live Tracking Screen (Next Milestone)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerShellScreen(
            initialIndex: 2, // Forces the bottom nav to start on Tracking Tab
            activeOrderId: orderId, // Passes live Firestore ID
          ),
        ),
            (route) => false, // Prevents Android back-button from returning to checkout
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: ThemesColors.brandOrange,
          content: Text('Failed to place order: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.appSurface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // 1. Top bar
            const SharedCustomerTopBar(
                title: 'Checkout Confirmation',
              showBackButton: true,
              showProfileButton: false,
            ),

            // 2. Scrollable review content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Section 1: Drop-off Address Card and Timing Toggle
                    CustomerDeliveryPinCard(
                      pin: CartItemModel.mockDropOffPin,
                      selectedTimingMode: _selectedTimingMode,
                      onTimingModeChanged: (DeliveryTimingMode mode) {
                        setState(() => _selectedTimingMode = mode);
                      },
                    ),

                    const SizedBox(height: 18),

                    // Section 2: Finalized Order Roll Summary
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ThemesColors.appSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ThemesColors.darkCharcoal
                              .withValues(alpha: 0.14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              const Text(
                                'Finalized Items',
                                style: TextStyle(
                                  color: ThemesColors.darkCharcoal,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${widget.cartItems.length} items',
                                style: TextStyle(
                                  color: ThemesColors.darkCharcoal
                                      .withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          ...widget.cartItems.map((CartItemModel item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: ThemesColors.darkCharcoal
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.fastfood_outlined,
                                      size: 18,
                                      color: ThemesColors.darkCharcoal,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          '${item.quantity}x • ${item.customizationTag}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: ThemesColors.darkCharcoal
                                                .withValues(alpha: 0.6),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'RM ${item.totalItemPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 3: Payment Method Selection
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ThemesColors.appSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ThemesColors.darkCharcoal
                              .withValues(alpha: 0.14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              color: ThemesColors.darkCharcoal,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _PaymentOptionTile(
                            title: "Touch 'n Go eWallet",
                            subtitle: 'Instant direct balance deduction',
                            isSelected:
                            _selectedPayment == PaymentMethod.tngEWallet,
                            onTap: () => setState(
                                  () => _selectedPayment =
                                  PaymentMethod.tngEWallet,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PaymentOptionTile(
                            title: 'Online Banking (FPX)',
                            subtitle: 'Maybank2u, CIMB Clicks, Public Bank',
                            isSelected: _selectedPayment ==
                                PaymentMethod.onlineBankingFpx,
                            onTap: () => setState(
                                  () => _selectedPayment =
                                  PaymentMethod.onlineBankingFpx,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _PaymentOptionTile(
                            title: 'Cash on Delivery',
                            subtitle: 'Pay when items arrived',
                            isSelected: _selectedPayment ==
                                PaymentMethod.cashOnDelivery,
                            onTap: () => setState(
                                  () => _selectedPayment =
                                  PaymentMethod.cashOnDelivery,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Section 4: Cost Matrix Breakdown
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: ThemesColors.appSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ThemesColors.darkCharcoal
                              .withValues(alpha: 0.14),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          _summaryRow(
                            'Items Subtotal',
                            'RM ${widget.subTotal.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 6),
                          _summaryRow(
                            'Direct Unstacked Delivery (<1km)',
                            'RM ${widget.deliveryFee.toStringAsFixed(2)}',
                            highlightColor: ThemesColors.freshGreen,
                          ),
                          const SizedBox(height: 6),
                          _summaryRow(
                            'Eco Packaging Fee',
                            'RM ${widget.packagingFee.toStringAsFixed(2)}',
                          ),
                          const Divider(height: 20),
                          _summaryRow(
                            'Total Payout',
                            'RM ${widget.totalAmount.toStringAsFixed(2)}',
                            isBold: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Final Place Order button
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _placeOrder,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        elevation: 0,
                        backgroundColor: ThemesColors.brandOrange,
                        foregroundColor: ThemesColors.appSurface,
                        disabledBackgroundColor: ThemesColors.brandOrange.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: ThemesColors.appSurface,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Confirm & Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
      String label,
      String amount, {
        bool isBold = false,
        Color? highlightColor,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: highlightColor ?? ThemesColors.darkCharcoal,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: highlightColor ??
                (isBold
                    ? ThemesColors.brandOrange
                    : ThemesColors.darkCharcoal),
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? ThemesColors.darkCharcoal.withValues(alpha: 0.04)
              : ThemesColors.appSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? ThemesColors.darkCharcoal
                : ThemesColors.darkCharcoal.withValues(alpha: 0.16),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: isSelected
                  ? ThemesColors.brandOrange
                  : ThemesColors.darkCharcoal.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: ThemesColors.darkCharcoal
                          .withValues(alpha: 0.6),
                      fontSize: 11,
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