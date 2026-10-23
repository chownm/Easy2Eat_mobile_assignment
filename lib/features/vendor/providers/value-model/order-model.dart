class OrderModel{
  final String orderID;
  final String customerName;
  final String orderItems;
  final String status;
  final String timeAgo;

  OrderModel({
    required this.orderID,
    required this.customerName,
    required this.orderItems,
    required this.status,
    required this.timeAgo,
  });
}