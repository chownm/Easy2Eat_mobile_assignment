import 'package:flutter/foundation.dart';
import 'package:easy2eat/features/customer/models/cart_item_model.dart';

class CartService {
  static final ValueNotifier<List<CartItemModel>> cartNotifier =
  ValueNotifier<List<CartItemModel>>([]);

  static List<CartItemModel> get items => cartNotifier.value;

  static void addItem(CartItemModel newItem) {
    final current = List<CartItemModel>.from(cartNotifier.value);
    final index = current.indexWhere((item) =>
    item.id == newItem.id &&
        item.customizationTag == newItem.customizationTag);

    if (index != -1) {
      final existing = current[index];
      current[index] =
          existing.copyWith(quantity: existing.quantity + newItem.quantity);
    } else {
      current.add(newItem);
    }
    cartNotifier.value = current;
  }

  static void removeItem(int index) {
    final current = List<CartItemModel>.from(cartNotifier.value);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      cartNotifier.value = current;
    }
  }

  static void incrementQuantity(int index) {
    final current = List<CartItemModel>.from(cartNotifier.value);
    if (index >= 0 && index < current.length) {
      final item = current[index];
      if (item.quantity < item.dailyPortionsRemaining) {
        current[index] = item.copyWith(quantity: item.quantity + 1);
        cartNotifier.value = current;
      }
    }
  }

  static void decrementQuantity(int index) {
    final current = List<CartItemModel>.from(cartNotifier.value);
    if (index >= 0 && index < current.length) {
      final item = current[index];
      if (item.quantity > 1) {
        current[index] = item.copyWith(quantity: item.quantity - 1);
        cartNotifier.value = current;
      }
    }
  }

  static void clearCart() {
    cartNotifier.value = [];
  }
}