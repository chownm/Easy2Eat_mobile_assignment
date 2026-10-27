class InventoryModel {
  final String itemID;
  final String itemName;
  final double price;
  final int availableStock;
  final String inventoryStatus;
  final String imageURL;

  InventoryModel({
    required this.itemID,
    required this.itemName,
    required this.price,
    required this.availableStock,
    required this.inventoryStatus,
    this.imageURL = '',
});

  InventoryModel copyWith ({
    String? itemID,
    String? itemName,
    double? price,
    int? availableStock,
    String? inventoryStatus,
    String? imageURL,
  }) {
    return InventoryModel(
      itemID: itemID ?? this.itemID,
      itemName: itemName ?? this.itemName,
      price: price ?? this.price,
      availableStock: availableStock ?? this.availableStock,
      inventoryStatus: inventoryStatus ?? this.inventoryStatus,
      imageURL: imageURL ?? this.imageURL,
    );
  }

  factory InventoryModel.fromJson(Map<String, dynamic> json, String documentID) {
    return InventoryModel(
        itemID: documentID,
        itemName: json['itemName'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        availableStock: json['availableStock'] ?? '0',
        inventoryStatus: json['inventoryStatus'] ?? 'in_stock',
        imageURL: json['imageURL'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'price': price,
      'availableStock': availableStock,
      'inventoryStatus': inventoryStatus,
      'imageURl': imageURL,
    };
  }
}