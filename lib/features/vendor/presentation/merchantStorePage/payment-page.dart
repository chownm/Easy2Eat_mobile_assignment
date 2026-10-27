import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';
import 'package:easy2eat/features/vendor/presentation/merchantStorePage/chartPage.dart';

class PaymentPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalPrice;
  final String customerName;

  const PaymentPage({
    Key? key,
    required this.cartItems,
    required this.totalPrice,
    required this.customerName,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedStoreLocation = 'APU Campus, Technology Park Malaysia';
  bool _isLoading = false;

  Future<void> _submitOrderAndDeductStock() async {
    if (_addressController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter real delivery address and phone number!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final firestore = FirebaseFirestore.instance;
      String orderID = "ORD-${DateTime.now().millisecondsSinceEpoch}";
      String qrID = "QR-${orderID}";

      String itemsSummary = widget.cartItems
          .map((ci) => "${ci.item.itemName} (x${ci.quantity})")
          .join(", ");

      OrderModel newOrder = OrderModel(
        orderID: orderID,
        qrID: qrID,
        customerName: widget.customerName,
        customerPhone: _phoneController.text.trim(),
        orderItems: itemsSummary,
        totalPrice: widget.totalPrice,
        status: 'pending',
        timeAgo: 'Just now',
        location: _selectedStoreLocation,
        createdAt: DateTime.now(),
      );

      WriteBatch batch = firestore.batch();

      DocumentReference orderRef = firestore.collection('orders').doc(orderID);
      Map<String, dynamic> orderData = newOrder.toJson();
      orderData['deliveryAddress'] = _addressController.text.trim();
      batch.set(orderRef, orderData);

      for (var cartItem in widget.cartItems) {
        DocumentReference inventoryRef = firestore.collection('inventory').doc(cartItem.item.itemID);
        batch.update(inventoryRef, {
          'availableStock': FieldValue.increment(-cartItem.quantity),
        });
      }

      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment simulated & Order placed successfully! Inventory updated.')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout & Payment Simulation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Total Amount: RM ${widget.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Customer Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Real Delivery Address (e.g., Residensi Park, Bukit Jalil)',
                hintText: 'Enter real address for rider navigation',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 15),
            const Text('Select Vendor Branch Location:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 5),
            DropdownButton<String>(
              value: _selectedStoreLocation,
              isExpanded: true,
              items: [
                'APU Campus, Technology Park Malaysia',
                'Pavilion Bukit Jalil, Lot 3.02',
                'Mid Valley Megamall, Lingkaran Syed Putra',
              ].map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
              onChanged: (val) => setState(() => _selectedStoreLocation = val!),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitOrderAndDeductStock,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirm Payment & Submit Order', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}