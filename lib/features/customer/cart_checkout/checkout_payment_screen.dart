import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/core/constants/user_session.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/cart_checkout/widgets/delivery_pin_card.dart';
import 'package:easy2eat/features/customer/customer_shell_screen.dart';
import 'package:easy2eat/features/customer/models/cart_item_model.dart';
import 'package:easy2eat/features/customer/models/order_tracking_model.dart';
import 'package:easy2eat/services/users/customer_profile_service.dart';
import 'package:easy2eat/shared/widgets/shared_customer_top_bar.dart';
import 'package:easy2eat/services/cart/cart_service.dart';

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

  // Live profile states (De-mocked)
  String _customerName = 'Valued Customer';
  String _customerPhone = '+60 12-000 0000';
  String _deliveryAddress = 'Cheras Traders Square • Block B';
  String _subPinLandmark = OrderTrackingModel.defaultSubPinLandmark;

  String get _currentUid =>
      FirebaseAuth.instance.currentUser?.uid ??
          UserSession.currentUid ??
          'CUST-101';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile =
    await CustomerProfileService.getProfileAndSettings(_currentUid);
    if (!mounted) return;

    setState(() {
      if (profile != null) {
        _customerName = profile.fullName;
        _customerPhone = profile.phoneNumber;
        if (profile.defaultDeliveryAddress.isNotEmpty) {
          _deliveryAddress = profile.defaultDeliveryAddress;
        }
        if (profile.defaultSubPinLandmark.isNotEmpty) {
          _subPinLandmark = profile.defaultSubPinLandmark;
        }
      } else {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _customerName = user.displayName ?? 'Customer';
          _customerPhone = user.phoneNumber ?? '+60 12-000 0000';
        }
      }
    });
  }

  /// Dynamic DropOffPinModel using live landmark instead of static mock
  DropOffPinModel get _currentPin => DropOffPinModel(
    hubZoneTitle: _deliveryAddress,
    microPinLandmark: _subPinLandmark,
    referencePhotoNote: 'Designated Food Drop Table • GPS Verified',
    distanceKm: 0.6,
    isDirectUnstackedEligible: true,
    scheduledShiftWindow: 'Today, 12:30 PM – 12:45 PM (Shift Break)',
  );

  void _showEditSubPinDialog() {
    final TextEditingController controller =
    TextEditingController(text: _subPinLandmark);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ThemesColors.appSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 38,
                height: 4.5,
                decoration: BoxDecoration(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Drop-Off Sub-Pin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ThemesColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Specify micro-drop point for couriers to drop your food',
              style: TextStyle(
                fontSize: 12,
                color: ThemesColors.darkCharcoal.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(
                color: ThemesColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                labelText: 'Sub-Pin Details',
                hintText: 'e.g., Gate Pillar 2 (Table), Lobby Guardhouse',
                labelStyle: TextStyle(
                  color: ThemesColors.darkCharcoal.withValues(alpha: 0.65),
                ),
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                  color: ThemesColors.brandOrange,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: ThemesColors.brandOrange,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final String newLandmark = controller.text.trim();
                  if (newLandmark.isNotEmpty) {
                    setState(() {
                      _subPinLandmark = newLandmark;
                      OrderTrackingModel.defaultSubPinLandmark = newLandmark;
                    });
                    CustomerProfileService.updateProfileField(
                      _currentUid,
                      {'defaultSubPinLandmark': newLandmark},
                    );
                    Navigator.pop(sheetContext);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemesColors.brandOrange,
                  foregroundColor: ThemesColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Update Sub-Pin',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _isProcessing = true);

    try {
      // 1. Generate live Order ID matching the team format
      final String orderId =
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // 2. Format cart items for the Vendor kitchen ticket
      final String orderItemsString = widget.cartItems
          .map((item) =>
      '${item.quantity}x ${item.title} (${item.customizationTag})')
          .join('\n');

      // 3. Resolve dynamic drop-off location
      final String dropOffLandmark = _subPinLandmark.isNotEmpty
          ? _subPinLandmark
          : OrderTrackingModel.defaultSubPinLandmark;
      final String fullDeliveryAddress =
          '$_deliveryAddress, $dropOffLandmark';

      // 4. Resolve vendor details dynamically from cart
      final String vendorId = widget.cartItems.isNotEmpty
          ? widget.cartItems.first.merchantId
          : "";
      final String vendorName = widget.cartItems.isNotEmpty
          ? widget.cartItems.first.merchantName
          : "";

      // 5. Aggregate dynamic item instructions
      final dynamicNotes = widget.cartItems
          .map((e) => e.customizationTag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .join(', ');
      final String orderNotes =
      dynamicNotes.isNotEmpty ? dynamicNotes : 'Standard preparation';

      // 6. Build the complete 5-stage order document
      final Map<String, dynamic> orderPayload = {
        // Identification
        'orderId': orderId,
        'orderID': orderId,
        'deliveryId': orderId,
        'qrID': orderId,
        'qrPayload': orderId,
        'qrBase64': '',

        // Customer Information (Pure dynamic values)
        'customerID': _currentUid,
        'customerName': _customerName,
        'customerPhone': _customerPhone,
        'deliveryAddress': fullDeliveryAddress,
        'dropOffLocation': 'Drop Off: $fullDeliveryAddress',
        'location': dropOffLandmark,
        'notes': orderNotes,

        // Vendor Information
        'vendorID': vendorId,
        'vendorName': vendorName,
        'pickupLocation': 'Pickup: $vendorName, Cheras C180 Hub',
        'orderItems': orderItemsString,

        // Financial Breakdown
        'itemsSubtotal': widget.subTotal,
        'deliveryFee': widget.deliveryFee,
        'taxAmount': 0.0,
        'totalPrice': widget.totalAmount,
        'earningAmount': 'RM ${widget.totalAmount.toStringAsFixed(2)}',
        'isPaid': true,
        'paymentMethod': _selectedPayment == PaymentMethod.tngEWallet
            ? "Touch 'n Go eWallet"
            : (_selectedPayment == PaymentMethod.onlineBankingFpx
            ? "Online Banking (FPX)"
            : "Cash on Gate Drop"),
        'paymentStatus': 'paid',

        // 5-Stage State Machine Initial Values
        'status': 'confirmed',
        'stage': 'confirmed',
        'preparationStatus': 'pending',
        'isPaused': false,
        'pauseReason': '',
        'minutesRemaining': 15,
        'statusDescription':
        'Order received. Kitchen has queued your ticket for prep.',
        'orderTime': 'Just now',
        'timeAgo': 'Just now',

        // Unassigned Courier Placeholders
        'assignedRiderId': null,
        'riderName': null,
        'riderPhone': null,
        'isPickedUp': false,
        'isDelivered': false,
        'pickedUpAt': null,
        'deliveredAt': null,

        // Timestamps
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // 7. Write to Firestore
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

      // Clear cart upon successful order creation
      CartService.clearCart();

      // 8. Route directly to Live Tracking (Tab 2) with the real order ID
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => CustomerShellScreen(
            initialIndex: 2,
            activeOrderId: orderId,
          ),
        ),
            (route) => false,
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
    return PopScope(
      canPop: !_isProcessing,
      child: Scaffold(
        backgroundColor: ThemesColors.appSurface,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              // Top Bar (Back button only, profile hidden per wireframe)
              const SharedCustomerTopBar(
                title: 'Checkout Confirmation',
                showBackButton: true,
                showProfileButton: false,
              ),

              // Scrollable Review Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Section 1: Drop-off Address Card & Timing Toggle
                      CustomerDeliveryPinCard(
                        pin: _currentPin,
                        selectedTimingMode: _selectedTimingMode,
                        onTimingModeChanged: (DeliveryTimingMode mode) {
                          setState(() => _selectedTimingMode = mode);
                        },
                        onEditPinTap: _showEditSubPinDialog,
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
                                padding:
                                const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: ThemesColors.darkCharcoal
                                            .withValues(alpha: 0.05),
                                        borderRadius:
                                        BorderRadius.circular(8),
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
                                    () =>
                                _selectedPayment = PaymentMethod.tngEWallet,
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
                              title: 'Cash on Gate Drop',
                              subtitle:
                              'Exact cash placed on pillar drop table',
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

                      // Final Place Order Button
                      ElevatedButton(
                        onPressed: _isProcessing ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          elevation: 0,
                          backgroundColor: ThemesColors.brandOrange,
                          foregroundColor: ThemesColors.appSurface,
                          disabledBackgroundColor:
                          ThemesColors.brandOrange.withValues(alpha: 0.5),
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
                      color:
                      ThemesColors.darkCharcoal.withValues(alpha: 0.6),
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