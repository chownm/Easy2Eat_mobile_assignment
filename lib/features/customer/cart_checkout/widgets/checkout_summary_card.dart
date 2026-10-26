import 'package:flutter/material.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/customer/models/cart_item_model.dart';

// Widget 4: Checkout Summary Card
class CustomerCheckoutSummaryCard extends StatelessWidget {
  final double subTotal;
  final double deliveryFee;
  final double packagingFee;
  final double totalAmount;
  final String buttonText;
  final VoidCallback onConfirmOrder;

  const CustomerCheckoutSummaryCard ({
    super.key,
    required this.subTotal,
    required this.deliveryFee,
    required this.packagingFee,
    required this.totalAmount,
    this.buttonText = 'Proceed to Checkout',
    required this.onConfirmOrder,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemesColors.appSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ThemesColors.darkCharcoal.withValues(alpha: 0.14),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Cost Matrix Breakdown',
            style: TextStyle(
              color: ThemesColors.darkCharcoal,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),

          _SummaryLineItem(
            label: 'Items Subtotal',
            amountText: 'RM ${subTotal.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 6),

          _SummaryLineItem(
            label: 'Direct Unstacked Delivery (<1km)',
            amountText: 'RM ${deliveryFee.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 6),

          _SummaryLineItem(
            label: 'Eco Packaging Fee',
            amountText: 'RM ${packagingFee.toStringAsFixed(2)}',
          ),

          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
              height: 1,
              thickness: 1,
              color: ThemesColors.darkCharcoal.withValues(alpha: 0.1),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Total Net Payout',
                style: TextStyle(
                  color: ThemesColors.darkCharcoal,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'RM ${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: ThemesColors.brandOrange,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          // Proceed to checkout button
          ElevatedButton(
            onPressed: totalAmount > 0 ? onConfirmOrder : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              elevation: 0,
              backgroundColor: ThemesColors.brandOrange,
              foregroundColor: ThemesColors.appSurface,
              disabledBackgroundColor:
              ThemesColors.darkCharcoal.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class _SummaryLineItem extends StatelessWidget {
  final String label;
  final String amountText;
  final bool isDiscountOrHighlight;

  const _SummaryLineItem ({
    required this.label,
    required this.amountText,
    this.isDiscountOrHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row (
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDiscountOrHighlight
                    ? ThemesColors.freshGreen
                    : ThemesColors.darkCharcoal.withValues(alpha: 0.75),
                fontSize: 12,
                fontWeight: isDiscountOrHighlight
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ) ,
        ),
        const SizedBox(width: 8),
        Text(
          amountText,
          style: TextStyle(
            color: isDiscountOrHighlight
                ? ThemesColors.freshGreen
                : ThemesColors.darkCharcoal,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        )
      ],
    );
  }
}