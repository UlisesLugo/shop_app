import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double ammount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {@required this.id,
      @required this.ammount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchProducts() async {
    final url = Uri.https(
        'shop-app-flutter3-default-rtdb.firebaseio.com', 'orders.json');
    final res = await http.get(url);
    final data = json.decode(res.body) as Map<String, dynamic>;
    final List<OrderItem> loadedOrders = [];

    if (data == null) {
      return; // No orders return early
    }

    data.forEach((key, value) {
      loadedOrders.add(
        OrderItem(
          id: key,
          ammount: value['ammount'],
          dateTime: DateTime.parse(value['dateTime']),
          products: (value['products'] as List<dynamic>)
              .map((ci) => CartItem(
                    id: ci['id'],
                    title: ci['title'],
                    quantity: ci['quantity'],
                    price: ci['price'],
                  ))
              .toList(),
        ),
      );
    });

    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(final List<CartItem> products, double total) async {
    final url = Uri.https(
        'shop-app-flutter3-default-rtdb.firebaseio.com', 'orders.json');
    final timestamp = DateTime.now();

    final res = await http.post(url,
        body: json.encode({
          'ammount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': products
              .map((el) => {
                    'id': el.id,
                    'price': el.price,
                    'quantity': el.quantity,
                    'title': el.title,
                  })
              .toList(),
        }));
    final newOrder = OrderItem(
      id: json.decode(res.body)['name'],
      ammount: total,
      products: products,
      dateTime: timestamp,
    );
    _orders.insert(0, newOrder);
    notifyListeners();
  }
}
