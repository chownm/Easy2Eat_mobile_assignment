import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Uncomment when connecting to Firestore
import '../value-model/inventory-model.dart';

class InventoryNotifier extends Notifier<List<InventoryModel>> {
  @override
  List<InventoryModel> build() {
    // Initial mock data matching InventoryModel schema
    return [
      InventoryModel(
        itemID: 'ITM-1',
        itemName: 'Truffle Burger',
        price: 25.0,
        availableStock: 10,
        inventoryStatus: 'in_stock',
        imageURL: '',
      ),
      InventoryModel(
        itemID: 'ITM-2',
        itemName: 'French Fries',
        price: 8.0,
        availableStock: 2,
        inventoryStatus: 'low_stock',
        imageURL: '',
      ),
      InventoryModel(
        itemID: 'ITM-3',
        itemName: 'Wagyu Bento',
        price: 35.0,
        availableStock: 0,
        inventoryStatus: 'sold_out',
        imageURL: '',
      ),
    ];
  }

  /// Reduce stock for a specific item (e.g., when ordered)
  void reduceStock(String itemID, int amount) {
    state = [
      for (final item in state)
        if (item.itemID == itemID)
          _calculateUpdatedItem(item, item.availableStock - amount, item.price)
        else
          item
    ];
    // TODO: Sync update to Firestore -> FirebaseFirestore.instance.collection('inventory').doc(itemID).update({'availableStock': ...});
  }

  /// Update price for a specific menu item
  void updatePrice(String itemID, double newPrice) {
    state = [
      for (final item in state)
        if (item.itemID == itemID)
          _calculateUpdatedItem(item, item.availableStock, newPrice)
        else
          item
    ];
    // TODO: Sync update to Firestore
  }

  /// Directly update stock quantity for a specific item
  void updateStock(String itemID, int newStock) {
    state = [
      for (final item in state)
        if (item.itemID == itemID)
          _calculateUpdatedItem(item, newStock, item.price)
        else
          item
    ];
    // TODO: Sync update to Firestore
  }

  /// Add a new item to the inventory list
  void addItem(String name, double price, int initialStock, {String imageURL = ''}) {
    int nextNumber = 1;
    if (state.isNotEmpty) {
      final numbers = state.map((e) {
        final parts = e.itemID.split('-');
        return parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
      });
      final maxNum = numbers.reduce((a, b) => a > b ? a : b);
      nextNumber = maxNum + 1;
    }

    final newItemID = 'ITM-$nextNumber';

    final newItem = _calculateUpdatedItem(
      InventoryModel(
        itemID: newItemID,
        itemName: name,
        price: price,
        availableStock: initialStock,
        inventoryStatus: 'in_stock',
        imageURL: imageURL,
      ),
      initialStock,
      price,
    );

    final updatedList = [...state, newItem];
    updatedList.sort((a, b) {
      int numA = int.tryParse(a.itemID.split('-').last) ?? 0;
      int numB = int.tryParse(b.itemID.split('-').last) ?? 0;
      return numA.compareTo(numB);
    });

    state = updatedList;
    // TODO: Sync creation to Firestore -> FirebaseFirestore.instance.collection('inventory').doc(newItemID).set(newItem.toJson());
  }

  /// Helper method to automatically calculate stock status based on available quantity
  InventoryModel _calculateUpdatedItem(InventoryModel item, int newStock, double price) {
    final validStock = newStock < 0 ? 0 : newStock;
    String status = 'in_stock';
    if (validStock == 0) {
      status = 'sold_out';
    } else if (validStock <= 5) {
      status = 'low_stock';
    }
    return item.copyWith(
      availableStock: validStock,
      price: price,
      inventoryStatus: status,
    );
  }
}

final inventoryProvider = NotifierProvider<InventoryNotifier, List<InventoryModel>>(() {
  return InventoryNotifier();
});