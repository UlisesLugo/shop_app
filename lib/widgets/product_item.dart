import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';

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
    final scaffold = ScaffoldMessenger.of(context);
    final _auth = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Hero(
            tag: _product.id,
            child: FadeInImage(
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(_product.imageUrl),
              fit: BoxFit.cover,
            ),
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
              onPressed: () async {
                try {
                  await _product.toggleFavorite(_auth.token, _auth.userId);
                } catch (error) {
                  print(error);
                  scaffold.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Updating failed!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
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
                  duration: Duration(seconds: 1),
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
