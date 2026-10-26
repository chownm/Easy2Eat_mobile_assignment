class OrderModel {
  final String orderID;
  final String qrID;
  final String customerName;
  final String customerPhone;
  final String orderItems;
  final double totalPrice;
  final String status;
  final String timeAgo;
  final String location;
  final DateTime? createdAt;

  // Rider delivery and pickup verification fields
  final String? assignedRiderId;
  final String? riderName;
  final String? riderPhone;
  final bool isPickedUp;
  final DateTime? pickedUpAt;

  OrderModel({
    required this.orderID,
    String? qrID,
    required this.customerName,
    this.customerPhone = '',
    required this.orderItems,
    this.totalPrice = 0.0,
    required this.status,
    this.timeAgo = '',
    this.location = '',
    this.createdAt,
    this.assignedRiderId,
    this.riderName,
    this.riderPhone,
    this.isPickedUp = false,
    this.pickedUpAt,
  }) : qrID = (qrID != null && qrID.isNotEmpty) ? qrID : orderID;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderID: json['orderID'] ?? '',
      qrID: json['qrID'] ?? json['orderID'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      orderItems: json['orderItems'] ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      timeAgo: json['timeAgo'] ?? '',
      location: json['location'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      assignedRiderId: json['assignedRiderId'],
      riderName: json['riderName'],
      riderPhone: json['riderPhone'],
      isPickedUp: json['isPickedUp'] ?? false,
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.tryParse(json['pickedUpAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderID': orderID,
      'qrID': qrID,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'orderItems': orderItems,
      'totalPrice': totalPrice,
      'status': status,
      'timeAgo': timeAgo,
      'location': location,
      'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      'assignedRiderId': assignedRiderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'isPickedUp': isPickedUp,
      'pickedUpAt': pickedUpAt?.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? orderID,
    String? qrID,
    String? customerName,
    String? customerPhone,
    String? orderItems,
    double? totalPrice,
    String? status,
    String? timeAgo,
    String? location,
    DateTime? createdAt,
    String? assignedRiderId,
    String? riderName,
    String? riderPhone,
    bool? isPickedUp,
    DateTime? pickedUpAt,
  }) {
    return OrderModel(
      orderID: orderID ?? this.orderID,
      qrID: qrID ?? this.qrID,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      orderItems: orderItems ?? this.orderItems,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      timeAgo: timeAgo ?? this.timeAgo,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      assignedRiderId: assignedRiderId ?? this.assignedRiderId,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      isPickedUp: isPickedUp ?? this.isPickedUp,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
    );
  }
}
