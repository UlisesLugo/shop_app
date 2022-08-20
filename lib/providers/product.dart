import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavorite(String token, String userId) async {
    var currFav = this.isFavorite;
    final url = Uri.https(
      'shop-app-flutter3-default-rtdb.firebaseio.com',
      'userFavorites/$userId/$id.json',
      {
        'auth': token,
      },
    );

    this.isFavorite = !this.isFavorite;
    notifyListeners();
    final res = await http.put(url, body: json.encode(this.isFavorite));

    if (res.statusCode >= 400) {
      this.isFavorite = currFav;
      notifyListeners();
      throw HttpException('Update favorite failed');
    }
    currFav = null;
  }
}
