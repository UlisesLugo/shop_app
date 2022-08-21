import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/splash.dart';

import './screens/auth_screen.dart';
import './screens/cart_screen.dart';
import '../screens/edit_product_screen.dart';
import './screens/orders_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/user_products_screen.dart';

import './providers/auth.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';

void main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => Auth(),
          ),
          // Dependencies within providers
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (context) => Products(null, null, []),
            update: (ctx, auth, prevProds) => Products(auth.token, auth.userId,
                prevProds == null ? [] : prevProds.items),
          ),
          ChangeNotifierProvider(
            create: (_) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (_) => Orders(null, null, []),
            update: (ctx, auth, prevOrders) => Orders(auth.token, auth.userId,
                prevOrders == null ? [] : prevOrders.orders),
          ),
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MyShop',
            theme: ThemeData(
                fontFamily: 'Lato',
                colorScheme:
                    ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                        .copyWith(secondary: Colors.deepOrange)),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Splash();
                      }
                      return AuthScreen();
                    }),
            routes: {
              // '/': (ctx) => ProductsOverviewScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
              // AuthScreen.routeName: (ctx) => AuthScreen(),
            },
          ),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
      ),
      body: Center(
        child: Text('Let\'s build a shop!'),
      ),
    );
  }
}
