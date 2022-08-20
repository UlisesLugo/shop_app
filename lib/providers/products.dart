import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  final String _token;
  final String _userId;

  Products(this._token, this._userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favorites {
    return _items.where((it) => it.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((el) => el.id == id);
  }

  Future<void> fetchProducts([bool filterByUser = false]) async {
    final url = Uri.https(
      'shop-app-flutter3-default-rtdb.firebaseio.com',
      'products.json',
      {
        'auth': _token,
        if (filterByUser) 'orderBy': '"creatorId"',
        if (filterByUser) 'equalTo': '"${_userId}"',
      },
    );
    final res = await http.get(url);
    final data = json.decode(res.body) as Map<String, dynamic>;
    if (data == null) {
      return;
    }
    final List<Product> loadedProducts = [];

    final favUrl = Uri.https(
      'shop-app-flutter3-default-rtdb.firebaseio.com',
      'userFavorites/$_userId.json',
      {
        'auth': _token,
      },
    );
    final favRes = await http.get(favUrl);
    final favData = json.decode(favRes.body);

    data.forEach((id, value) {
      loadedProducts.add(
        Product(
          id: id,
          title: value['title'],
          description: value['description'],
          price: value['price'],
          isFavorite: favData == null ? false : (favData[id] ?? false),
          imageUrl: value['imageUrl'],
        ),
      );
    });

    _items = loadedProducts;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https(
      'shop-app-flutter3-default-rtdb.firebaseio.com',
      'products.json',
      {
        'auth': _token,
      },
    );
    final res = await http.post(
      url,
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'creatorId': _userId,
      }),
    );
    final newProduct = Product(
      id: json.decode(res.body)['name'],
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    );
    _items.add(newProduct);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    var index = _items.indexWhere((pr) => product.id == pr.id);
    final url = Uri.https(
      'shop-app-flutter3-default-rtdb.firebaseio.com',
      'products/${product.id}.json',
      {
        'auth': _token,
      },
    );
    if (index >= 0) {
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }));
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    var index = _items.indexWhere((pr) => productId == pr.id);
    final url = Uri.https(
      'shop-app-flutter3-default-rtdb.firebaseio.com',
      'products/$productId.json',
      {
        'auth': _token,
      },
    );

    if (index >= 0) {
      var product = _items[index];
      _items.removeAt(index);
      notifyListeners();

      final res = await http.delete(url);
      if (res.statusCode >= 400) {
        _items.insert(index, product); // Optimistic updating
        notifyListeners();
        throw HttpException('Could not delete product.');
      }

      product = null;
    }
  }
}

// Example images
// Two schnauzers:
// https://t2.uc.ltmcdn.com/es/posts/5/1/3/como_saber_si_un_schnauzer_es_de_raza_50315_600_square.jpg
