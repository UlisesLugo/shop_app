import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

import '../providers/orders.dart' show Orders;

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future<void> _refreshOrders(BuildContext ctx) async {
    await Provider.of<Orders>(ctx, listen: false).fetchProducts();
  }

  @override
  void initState() {
    _ordersFuture = _refreshOrders(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Your orders')),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (dataSnapshot.hasError) {
              return Center(
                child: Text('There was an error loading '),
              );
            }
            return Consumer<Orders>(builder: (ctx2, orderData, child) {
              return RefreshIndicator(
                onRefresh: () => _refreshOrders(context),
                child: ListView.builder(
                  itemBuilder: (ctx, i) {
                    return OrderItem(orderData.orders[i]);
                  },
                  itemCount: orderData.orders.length,
                ),
              );
            });
          },
        ));
  }
}
