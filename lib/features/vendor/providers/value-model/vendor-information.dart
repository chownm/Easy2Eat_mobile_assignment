// This file use to define vendor information and pass it into firestone database

class VendorModel{
  // Parameters Definition:
  final String vendorID;
  final String vendorName;
  final String vendorOwner;
  final String phoneNumber;
  final String storeLocation;
  final String imageURL;
  final bool isOpen;

  VendorModel({
    required this.vendorID,
    required this.vendorName,
    required this.vendorOwner,
    required this.phoneNumber,
    required this.storeLocation,
    this.imageURL = '',
    this.isOpen = true,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json, String documentID) {
    return VendorModel(
        vendorID: documentID,
        vendorName: json['vendorName'] ?? '',
        vendorOwner: json['vendorOwner'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        storeLocation: json['storeLocation'] ?? '',
        imageURL: json['imageURL'] ?? '',
        isOpen: json['isOpen'] ?? true,
    );
  }

  Map<String, dynamic> toJson(){
      return {
        'vendorName' : vendorName,
        'vendorOwner' : vendorOwner,
        'phoneNumber' : phoneNumber,
        'storeLocation' : storeLocation,
        'imageURL' : imageURL,
        'isOpen' : isOpen
      };
  }

  VendorModel copyWith({
    String? vendorID,
    String? vendorName,
    String? vendorOwner,
    String? phoneNumber,
    String? storeLocation,
    String? imageURL,
    bool? isOpen,
  }) {
    return VendorModel(
        vendorID: vendorID ?? this.vendorID,
        vendorName: vendorName ?? this.vendorName,
        vendorOwner: vendorOwner ?? this.vendorOwner,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        storeLocation: storeLocation ?? this.storeLocation,
        imageURL: imageURL ?? this.imageURL,
        isOpen: isOpen ?? this.isOpen,
    );
  }
}