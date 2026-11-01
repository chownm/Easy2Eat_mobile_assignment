class OrderModel {
  final String orderID;
  final String qrID;

  // 🏢 Vendor Information
  final String vendorID;
  final String vendorName;

  final String customerID;
  final String customerName;
  final String customerPhone;
  final String orderItems;

  // Financial & Pricing Breakdown
  final double itemsSubtotal;
  final double deliveryFee;
  final double taxAmount;
  final double totalPrice;
  final bool isPaid;
  final String paymentStatus;
  final String paymentMethod;

  final String status;         // Riders to update order status (address to delivery status)
  final String preparationStatus; // Vendor to update order status
  final String timeAgo;
  final String location;       // Store / Pickup branch location
  final String deliveryAddress;// Customer delivery address
  final DateTime? createdAt;
  final String notes;

  // Rider delivery and pickup verification fields
  final String? assignedRiderId;
  final String? riderName;
  final String? riderPhone;
  final bool isPickedUp;
  final DateTime? pickedUpAt;
  final bool isDelivered;
  final DateTime? deliveredAt;

  OrderModel({
    required this.orderID,
    String? qrID,
    this.vendorID = '',
    this.vendorName = '',
    this.customerID = '',
    required this.customerName,
    this.customerPhone = '',
    required this.orderItems,
    this.itemsSubtotal = 0.0,
    this.deliveryFee = 5.00,
    this.taxAmount = 0.0,
    double? totalPrice,
    bool? isPaid,
    String? paymentStatus,
    this.paymentMethod = 'Credit Card',
    required this.status,
    String? preparationStatus,
    this.timeAgo = '',
    this.location = '',
    this.deliveryAddress = '',
    this.createdAt,
    this.notes = '',
    this.assignedRiderId,
    this.riderName,
    this.riderPhone,
    this.isPickedUp = false,
    this.pickedUpAt,
    this.isDelivered = false,
    this.deliveredAt,
  })  : qrID = (qrID != null && qrID.isNotEmpty) ? qrID : orderID,
        totalPrice = totalPrice ?? (itemsSubtotal + deliveryFee + taxAmount),
        isPaid = isPaid ?? (paymentStatus == 'paid' || true),
        paymentStatus = paymentStatus ?? ((isPaid ?? true) ? 'paid' : 'unpaid'),
        preparationStatus = preparationStatus ?? (status == 'pending' ? 'received' : status);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    bool parsedIsPaid = json['isPaid'] ?? (json['paymentStatus'] == 'paid');
    String baseStatus = json['status'] ?? 'pending';
    return OrderModel(
      orderID: json['orderID'] ?? json['deliveryId'] ?? '',
      qrID: json['qrID'] ?? json['orderID'] ?? '',
      vendorID: json['vendorID'] ?? '',
      vendorName: json['vendorName'] ?? '',
      customerID: json['customerID'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      orderItems: json['orderItems'] ?? '',
      itemsSubtotal: (json['itemsSubtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      isPaid: parsedIsPaid,
      paymentStatus: json['paymentStatus'] ?? (parsedIsPaid ? 'paid' : 'unpaid'),
      paymentMethod: json['paymentMethod'] ?? 'Credit Card',
      status: baseStatus,
      preparationStatus: json['preparationStatus'] ?? baseStatus,
      timeAgo: json['timeAgo'] ?? json['orderTime'] ?? '',
      location: json['location'] ?? json['pickupLocation'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? json['dropOffLocation'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      notes: json['notes'] ?? '',
      assignedRiderId: json['assignedRiderId'],
      riderName: json['riderName'],
      riderPhone: json['riderPhone'],
      isPickedUp: json['isPickedUp'] ?? false,
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.tryParse(json['pickedUpAt'].toString())
          : null,
      isDelivered: json['isDelivered'] ?? (baseStatus == 'delivered'),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'deliveryId': orderID, // Compatible with teammate's rider-side deliveryId
      'qrID': qrID,
      'vendorID': vendorID,
      'vendorName': vendorName,
      'customerID': customerID,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'orderItems': orderItems,
      'itemsSubtotal': itemsSubtotal,
      'deliveryFee': deliveryFee,
      'taxAmount': taxAmount,
      'totalPrice': totalPrice,
      'earningAmount': 'RM ${totalPrice.toStringAsFixed(2)}', // Compatible with teammate's rider-side earningAmount
      'isPaid': isPaid,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'status': status,
      'preparationStatus': preparationStatus,
      'timeAgo': timeAgo,
      'orderTime': timeAgo, // Compatible with teammate's orderTime
      'location': location,
      'pickupLocation': location.isNotEmpty ? 'Pickup: $location' : 'Pickup: Store', // Compatible with teammate's pickupLocation
      'deliveryAddress': deliveryAddress,
      'dropOffLocation': deliveryAddress.isNotEmpty ? 'Drop Off: $deliveryAddress' : 'Drop Off: Customer', // Compatible with teammate's dropOffLocation
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'notes': notes,
      'assignedRiderId': assignedRiderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'isPickedUp': isPickedUp,
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'isDelivered': isDelivered,
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? orderID,
    String? qrID,
    String? vendorID,
    String? vendorName,
    String? customerID,
    String? customerName,
    String? customerPhone,
    String? orderItems,
    double? itemsSubtotal,
    double? deliveryFee,
    double? taxAmount,
    double? totalPrice,
    bool? isPaid,
    String? paymentStatus,
    String? paymentMethod,
    String? status,
    String? preparationStatus,
    String? timeAgo,
    String? location,
    String? deliveryAddress,
    DateTime? createdAt,
    String? notes,
    String? assignedRiderId,
    String? riderName,
    String? riderPhone,
    bool? isPickedUp,
    DateTime? pickedUpAt,
    bool? isDelivered,
    DateTime? deliveredAt,
  }) {
    final newSubtotal = itemsSubtotal ?? this.itemsSubtotal;
    final newDeliveryFee = deliveryFee ?? this.deliveryFee;
    final newTaxAmount = taxAmount ?? this.taxAmount;
    final newIsPaid = isPaid ?? this.isPaid;

    return OrderModel(
      orderID: orderID ?? this.orderID,
      qrID: qrID ?? this.qrID,
      vendorID: vendorID ?? this.vendorID,
      vendorName: vendorName ?? this.vendorName,
      customerID: customerID ?? this.customerID,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      orderItems: orderItems ?? this.orderItems,
      itemsSubtotal: newSubtotal,
      deliveryFee: newDeliveryFee,
      taxAmount: newTaxAmount,
      totalPrice: totalPrice ?? (newSubtotal + newDeliveryFee + newTaxAmount),
      isPaid: newIsPaid,
      paymentStatus: paymentStatus ?? (newIsPaid ? 'paid' : 'unpaid'),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      preparationStatus: preparationStatus ?? this.preparationStatus,
      timeAgo: timeAgo ?? this.timeAgo,
      location: location ?? this.location,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      assignedRiderId: assignedRiderId ?? this.assignedRiderId,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      isPickedUp: isPickedUp ?? this.isPickedUp,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      isDelivered: isDelivered ?? this.isDelivered,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}