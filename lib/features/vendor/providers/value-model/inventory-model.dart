class InventoryModel {
  final String itemID;          // Firestore Document ID
  final String itemName;        // Name of the menu item / product
  final double price;           // Price of the item
  final int availableStock;     // Current available stock quantity
  final String inventoryStatus; // Status e.g., 'in_stock', 'low_stock', 'out_of_stock'
  final String imageURL;        // Product image URL (e.g., Firebase Storage)

  InventoryModel({
    required this.itemID,
    required this.itemName,
    required this.price,
    required this.availableStock,
    required this.inventoryStatus,
    this.imageURL = '',
  });

  /// Create a copy of InventoryModel with updated fields
  InventoryModel copyWith({
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

  /// Factory constructor to parse Firestore Document Snapshot into InventoryModel
  factory InventoryModel.fromJson(Map<String, dynamic> json, String documentID) {
    return InventoryModel(
      itemID: documentID,
      itemName: json['itemName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      inventoryStatus: json['inventoryStatus'] ?? 'in_stock',
      imageURL: json['imageURL'] ?? '',
    );
  }

  /// Convert InventoryModel to a Map for saving/updating in Firestore database
  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'price': price,
      'availableStock': availableStock,
      'inventoryStatus': inventoryStatus,
      'imageURL': imageURL, // Fixed casing to match standard naming
    };
  }
}