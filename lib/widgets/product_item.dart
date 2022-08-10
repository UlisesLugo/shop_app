import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../screens/product_detail_screen.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final _product = Provider.of<Product>(context, listen: false);
    final _cart = Provider.of<Cart>(context, listen: false);

    print('rebuilid product');
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Image.network(
            _product.imageUrl,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDetailScreen.routeName, arguments: _product.id
                    // MaterialPageRoute(builder: (ctx) {
                    //   return ProductDetailScreen(_product);
                    // }),
                    );
          },
        ),
        footer: GridTileBar(
          leading: Consumer<Product>(
            builder: (_, dproduct, child) => IconButton(
              icon: Icon(
                  _product.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () => _product.toggleFavorite(),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          title: Text(
            _product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              _cart.addItem(_product.id, _product.price, _product.title);
              // Scaffold.of(context).showSnackBar(
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added item to cart!'),
                  duration: Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      _cart.removeSingleItem(_product.id);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).colorScheme.secondary,
          ),
          backgroundColor: Colors.black87,
        ),
      ),
    );
  }
}
