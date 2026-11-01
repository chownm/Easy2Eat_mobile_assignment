import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy2eat/core/theme/theme.dart';
import 'package:easy2eat/features/vendor/providers/value-model/inventory-model.dart';
import 'package:easy2eat/features/vendor/presentation/InventoryDetails/inventory-management.dart';

/// 1. Main Master Page for Stock & Inventory Management
class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemesColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: ThemesColors.appSurface,
        elevation: 0,
        title: const Text(
          'Inventory Management',
          style: TextStyle(
            color: ThemesColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      // Render the dedicated inventory list & control widget safely
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: InventoryListWidget(), // 👈 Fixed: Using InventoryListWidget instead of self-recursion
      ),
    );
  }
}

/// 2. Dedicated Widget for Inventory List & Firestore Live Controls
class InventoryListWidget extends StatefulWidget {
  const InventoryListWidget({super.key});

  @override
  State<InventoryListWidget> createState() => _InventoryListWidgetState();
}

class _InventoryListWidgetState extends State<InventoryListWidget> {
  // Future to manage native Firestore inventory loading
  late Future<List<InventoryModel>> _inventoryFuture;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  // Load or refresh inventory list from Cloud Firestore
  void _loadInventory() {
    setState(() {
      _inventoryFuture = InventoryService.fetchAndEnsureInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InventoryModel>>(
      future: _inventoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final inventoryList = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Stock & Inventory Control',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ThemesColors.darkCharcoal,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemesColors.primaryButton,
                    foregroundColor: ThemesColors.textOnPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showAddItemDialog(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Item', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            inventoryList.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No inventory items found.', style: TextStyle(color: Colors.grey)),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: inventoryList.length,
              itemBuilder: (context, index) {
                final item = inventoryList[index];
                bool isSoldOut = item.availableStock == 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSoldOut ? Colors.grey.shade100 : ThemesColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSoldOut ? Colors.grey.shade300 : Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.itemName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isSoldOut ? Colors.grey : ThemesColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${item.itemID})',
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Edit item price dialog trigger
                            InkWell(
                              onTap: () => _showEditPriceDialog(context, item),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'RM ${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ThemesColors.textPrimary),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit, size: 12, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isSoldOut ? ThemesColors.error.withOpacity(0.1) : ThemesColors.darkCharcoal.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isSoldOut ? 'SOLD OUT' : 'Stock: ${item.availableStock}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSoldOut ? ThemesColors.error : ThemesColors.darkCharcoal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stock Management Control Buttons (+ / -)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 32, color: ThemesColors.darkCharcoal),
                            onPressed: () async {
                              if (item.availableStock > 0) {
                                await InventoryService.updateStock(item.itemID, item.availableStock - 1);
                                _loadInventory();
                              }
                            },
                          ),
                          Text(
                            '${item.availableStock}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: ThemesColors.textPrimary),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 22, color: ThemesColors.textPrimary),
                            onPressed: () async {
                              await InventoryService.updateStock(item.itemID, item.availableStock + 1);
                              _loadInventory();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Dialog to edit item price
  void _showEditPriceDialog(BuildContext context, InventoryModel item) {
    final priceController = TextEditingController(text: item.price.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemesColors.appSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Price: ${item.itemName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'New Price (RM)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: ThemesColors.primaryButton, width: 2)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemesColors.primaryButton, foregroundColor: ThemesColors.textOnPrimary),
            onPressed: () async {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null && newPrice >= 0) {
                await InventoryService.updatePrice(item.itemID, newPrice);
                _loadInventory();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Dialog to add a new inventory item
  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemesColors.appSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price (RM)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Initial Stock', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemesColors.primaryButton, foregroundColor: ThemesColors.textOnPrimary),
            onPressed: () async {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text) ?? 0.0;
              final stock = int.tryParse(stockController.text) ?? 0;

              if (name.isNotEmpty && price > 0) {
                await InventoryService.addItem(name, price, stock);
                _loadInventory();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}