class InventoryModel {
  final String itemID;
  final String itemName;
  final double price;
  final int availableStock;
  final String inventoryStatus;

  InventoryModel({
    required this.itemID,
    required this.itemName,
    required this.price,
    required this.availableStock,
    required this.inventoryStatus,
});

  InventoryModel copyWith ({
    String? itemID,
    String? itemName,
    double? price,
    int? availableStock,
    String? inventoryStatus,
  }) {
    return InventoryModel(
        itemID: itemID ?? this.itemID,
        itemName: itemName ?? this.itemName,
        price: price ?? this.price,
        availableStock: availableStock ?? this.availableStock,
        inventoryStatus: inventoryStatus ?? this.inventoryStatus,
    );
  }
}