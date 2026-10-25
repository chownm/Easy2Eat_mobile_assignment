import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../value-model/inventory-model.dart';

class InventoryNotifier extends Notifier<List<InventoryModel>> {
  @override
  List<InventoryModel> build() {
    return [
      InventoryModel(
        itemID: 'ITM-1',
        itemName: 'Truffle Burger',
        price: 25.0,
        availableStock: 10,
        inventoryStatus: 'in_stock',
      ),
      InventoryModel(
        itemID: 'ITM-2',
        itemName: 'French Fries',
        price: 8.0,
        availableStock: 2,
        inventoryStatus: 'low_stock',
      ),
      InventoryModel(
        itemID: 'ITM-3',
        itemName: 'Wagyu Bento',
        price: 35.0,
        availableStock: 0,
        inventoryStatus: 'sold_out',
      ),
    ];
  }

  void reduceStock(String itemID, int amount) {
    state = [
      for (final item in state)
        if (item.itemID == itemID)
          _calculateUpdatedItem(item, item.availableStock - amount, item.price)
        else
          item
    ];
  }

  void updatePrice(String itemID, double newPrice) {
    state = [
      for (final item in state)
        if (item.itemID == itemID)
          item..copyWith(price: newPrice)
        else
          item
    ];
  }

  void updateStock(String itemID, int newStock) {
    state = [
      for (final item in state)
        if (item.itemID == itemID)
          _calculateUpdatedItem(item, newStock, item.price)
        else
          item
    ];
  }

  void addItem(String name, double price, int initialStock) {
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
      ),
      initialStock,
      price,
    );

    final updatedList = [...state, newItem];
    updatedList.sort((a, b) {
      int numA = int.tryParse(a.itemID
          .split('-')
          .last) ?? 0;
      int numB = int.tryParse(b.itemID
          .split('-')
          .last) ?? 0;
      return numA.compareTo(numB);
    });

    state = updatedList;
  }

  InventoryModel _calculateUpdatedItem(InventoryModel item, int newStock,
      double price) {
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
