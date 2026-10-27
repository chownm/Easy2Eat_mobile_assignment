import 'package:flutter/material.dart';
import 'package:easy2eat/features/vendor/providers/value-model/inventory-model.dart';
import 'package:easy2eat/features/vendor/presentation/merchantStorePage/payment-page.dart';

class CartItem {
  final InventoryModel item;
  int quantity;
  CartItem({required this.item, required this.quantity});
}

class CartPage extends StatelessWidget {
  final Map<String, CartItem> cartMap;
  final Function(String, int) onUpdateQuantity;
  final String customerName;

  const CartPage({
    Key? key,
    required this.cartMap,
    required this.onUpdateQuantity,
    required this.customerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartItems = cartMap.values.toList();
    double totalPrice = cartItems.fold(0, (sum, ci) => sum + (ci.item.price * ci.quantity));

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cartItems.isEmpty
          ? const Center(child: Text('Your cart is empty. Go add some food!'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                var cartItem = cartItems[index];
                return ListTile(
                  title: Text(cartItem.item.itemName),
                  subtitle: Text('RM ${cartItem.item.price} x ${cartItem.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => onUpdateQuantity(cartItem.item.itemID, -1),
                      ),
                      Text('${cartItem.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => onUpdateQuantity(cartItem.item.itemID, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -2))],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('RM ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            cartItems: cartItems,
                            totalPrice: totalPrice,
                            customerName: customerName,
                          ),
                        ),
                      );
                    },
                    child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}