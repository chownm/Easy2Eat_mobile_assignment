import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';

class OrderListNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() {
    return [
      OrderModel(
        orderID: 'ORD-9824',
        customerID: 'CUST-001',
        customerName: 'Alex',
        customerPhone: '+60123456789',
        orderItems: '2x Big Mac, 1x French Fries',
        itemsSubtotal: 35.00,
        deliveryFee: 5.00,
        taxAmount: 2.40,
        isPaid: true,
        paymentMethod: 'Credit Card',
        status: 'pending',
        timeAgo: '2 mins ago',
        location: 'APU Campus Cafeteria, Bukit Jalil',
        deliveryAddress: 'Residensi Park, Bukit Jalil, KL',
        notes: 'Less ice on drinks, please.',
      ),
    ];
  }

  /// Update the entire list of orders in real-time state
  void updateOrders(List<OrderModel> newOrders) {
    state = newOrders;
  }
}

final orderListProvider = NotifierProvider<OrderListNotifier, List<OrderModel>>(() {
  return OrderListNotifier();
});