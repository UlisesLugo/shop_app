import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<Products>(ctx, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final _products = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: () => _refreshProducts(context),
            child: Consumer<Products>(
              builder: (ctx, products, _) => Padding(
                padding: EdgeInsets.all(8),
                child: ListView.builder(
                  itemBuilder: (_, i) {
                    return Column(
                      children: [
                        UserProductItem(
                          products.items[i].id,
                          products.items[i].title,
                          products.items[i].imageUrl,
                        ),
                        Divider(),
                      ],
                    );
                  },
                  itemCount: products.items.length,
                ),
              ),
            ),
          );
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
