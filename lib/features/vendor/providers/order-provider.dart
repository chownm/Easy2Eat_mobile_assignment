import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy2eat/features/vendor/providers/value-model/order-model.dart';

class orderListNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() {
    return [
      OrderModel(
        orderID: 'ORD-9824',
        customerName: 'Alex',
        orderItems: '2x Big Mac, 1x French Fries',
        status: 'pending',
        timeAgo: '2 mins ago',
      ),
      OrderModel(
        orderID: 'ORD-1234',
        customerName: 'Genji',
        orderItems: '1x Speghati, 1x Pizza',
        status: 'preparing',
        timeAgo: '10 mins ago',
      ),
      OrderModel(
        orderID: 'ORD-3254',
        customerName: 'Stephord',
        orderItems: '1x Nasi Lemak, 1x telur',
        status: 'almost done',
        timeAgo: '15 mins ago',
      ),
      OrderModel(
        orderID: 'ORD-12345',
        customerName: 'Chow',
        orderItems: '1x Pizza',
        status: 'pending',
        timeAgo: '8 mins ago',
      ),
      OrderModel(
          orderID: 'ORD-4568',
          customerName: 'Vegetarian',
          orderItems: '1x Rib eye Steak',
          status: 'preparing',
          timeAgo: '15 mins ago'
      ),
    ];
  }

  void updateOrders(List<OrderModel> newOrders) {
    state = newOrders;
  }
}

final orderListProvider = NotifierProvider<orderListNotifier, List<OrderModel>>(() {
  return orderListNotifier();
});