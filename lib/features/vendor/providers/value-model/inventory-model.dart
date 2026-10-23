class InventoryModel {
  final String itemID;
  final String itemName;
  final double price;
  final int availableStock;
  final String inventoryStatus;
  final String category;

  InventoryModel({
    required this.itemID,
    required this.itemName,
    required this.price,
    required this.availableStock,
    required this.inventoryStatus,
    required this.category,
});
}