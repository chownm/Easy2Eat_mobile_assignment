import 'package:easy2eat/features/vendor/presentation/merchantStorePage/chartPage.dart';
import 'package:easy2eat/features/vendor/presentation/merchantStorePage/itemPage.dart';
import 'package:easy2eat/features/vendor/providers/value-model/inventory-model.dart';
import 'package:flutter/material.dart';

class CustomerMainUi extends StatefulWidget {
  const CustomerMainUi({Key? key}) : super(key: key);

  @override
  State<CustomerMainUi> createState() => _CustomerMainUiState();
}

class _CustomerMainUiState extends State<CustomerMainUi> {
  int _currentIndex = 0;
  final Map<String, CartItem> _cartMap = {};
  final String _customerName = "Alex Wong";

  void _handleAddToCart(InventoryModel item, int quantity) {
    setState(() {
      if (_cartMap.containsKey(item.itemID)) {
        _cartMap[item.itemID]!.quantity += quantity;
      } else {
        _cartMap[item.itemID] = CartItem(item: item, quantity: quantity);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${item.itemName} to cart!'), duration: const Duration(milliseconds: 800)),
    );
  }

  void _handleUpdateQuantity(String itemID, int delta) {
    setState(() {
      if (_cartMap.containsKey(itemID)) {
        _cartMap[itemID]!.quantity += delta;
        if (_cartMap[itemID]!.quantity <= 0) {
          _cartMap.remove(itemID);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      ItemPage(onAddToCart: _handleAddToCart),
      CartPage(
        cartMap: _cartMap,
        onUpdateQuantity: _handleUpdateQuantity,
        customerName: _customerName,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        ],
      ),
    );
  }
}