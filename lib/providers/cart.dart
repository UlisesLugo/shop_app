import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {@required this.id,
      @required this.title,
      @required this.quantity,
      @required this.price});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items == null ? 0 : _items.length;
  }

  int get totalProducts {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity * cartItem.price;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (ci) => CartItem(
            id: ci.id,
            title: ci.title,
            quantity: ci.quantity + 1,
            price: ci.price),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
            id: DateTime.now().toString(),
            title: title,
            quantity: 1,
            price: price),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (ci) => CartItem(
              id: ci.id,
              title: ci.title,
              quantity: ci.quantity - 1,
              price: ci.price));
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
