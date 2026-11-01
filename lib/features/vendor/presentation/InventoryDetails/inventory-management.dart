import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/features/vendor/providers/value-model/inventory-model.dart';

class InventoryService {
  /// 1. Fetch all inventory items from Firestore. If empty, seed initial mock data for testing.
  static Future<List<InventoryModel>> fetchAndEnsureInventory() async {
    try {
      final collectionRef = FirebaseFirestore.instance.collection('inventory');
      final snapshot = await collectionRef.get();

      if (snapshot.docs.isEmpty) {
        debugPrint("Firestore 'inventory' is empty. Seeding initial stock...");
        await _seedInitialInventory(collectionRef);
        final freshSnapshot = await collectionRef.get();
        return freshSnapshot.docs
            .map((doc) => InventoryModel.fromJson(doc.data(), doc.id))
            .toList();
      }

      return snapshot.docs
          .map((doc) => InventoryModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint("Failed to fetch inventory: $e");
      return [];
    }
  }

  /// 2. Helper to seed initial stock items into Firestore
  static Future<void> _seedInitialInventory(CollectionReference collectionRef) async {
    final List<InventoryModel> initialItems = [
      InventoryModel(
        itemID: 'ITEM-001',
        itemName: 'Big Mac',
        price: 15.00,
        availableStock: 20,
        inventoryStatus: 'in_stock',
      ),
      InventoryModel(
        itemID: 'ITEM-002',
        itemName: 'French Fries',
        price: 6.00,
        availableStock: 50,
        inventoryStatus: 'in_stock',
      ),
      InventoryModel(
        itemID: 'ITEM-003',
        itemName: 'Teh Tarik',
        price: 4.50,
        availableStock: 30,
        inventoryStatus: 'in_stock',
      ),
    ];

    for (var item in initialItems) {
      await collectionRef.doc(item.itemID).set(item.toJson(), SetOptions(merge: true));
    }
  }

  /// 3. Update specific item stock quantity in Firestore
  static Future<void> updateStock(String itemID, int newStock) async {
    try {
      String status = newStock == 0 ? 'out_of_stock' : (newStock < 5 ? 'low_stock' : 'in_stock');
      await FirebaseFirestore.instance.collection('inventory').doc(itemID).update({
        'availableStock': newStock < 0 ? 0 : newStock,
        'inventoryStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Failed to update stock: $e");
    }
  }

  /// 4. Update specific item price in Firestore
  static Future<void> updatePrice(String itemID, double newPrice) async {
    try {
      await FirebaseFirestore.instance.collection('inventory').doc(itemID).update({
        'price': newPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Failed to update price: $e");
    }
  }

  /// 5. Add a new menu item to Firestore
  static Future<void> addItem(String name, double price, int stock) async {
    try {
      String itemID = 'ITEM-${DateTime.now().millisecondsSinceEpoch}';
      InventoryModel newItem = InventoryModel(
        itemID: itemID,
        itemName: name,
        price: price,
        availableStock: stock,
        inventoryStatus: stock > 0 ? 'in_stock' : 'out_of_stock',
      );
      await FirebaseFirestore.instance.collection('inventory').doc(itemID).set(newItem.toJson());
    } catch (e) {
      debugPrint("Failed to add item: $e");
    }
  }
}