import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piratebay/models/order.dart';
import 'package:piratebay/providers/auth.dart';
import 'package:piratebay/providers/orders.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class OrderManageScreen extends StatefulWidget {
  @override
  _OrderManageScreenState createState() => new _OrderManageScreenState();
}

class _OrderManageScreenState extends State<OrderManageScreen> {
  List<Order> list = [];
  Auth auth;
  int _currentIndex = 0;
  // var refreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  Orders _orders;

  @override
  void initState() {
    super.initState();

    refreshList();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   refreshList();
  // }

  Future<void> refreshList() async {
    _orders = Provider.of<Orders>(context, listen: false);
    List<Order> listAux = await _orders.fetchAndSetOrders();

    if (listAux != null) {
      // print(listAux);
      setState(() {
        list = listAux;
      });
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Active Orders"),
      ),
      body:
      list.length != 0
          ? RefreshIndicator(
              // key: refreshKey,
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text('Order Id: ${list[i].orderId}'),
                  // subtitle: Text('Username: ${list[i]['username']}'),
                  subtitle: Column(
                    children: <Widget>[
                      Text('Date: ${DateFormat.yMEd().add_jms().format(DateTime.parse(list[i].orderDate))}'),
                      Text('Client: ${list[i].userOrder.username}'),
                      Text('Addres: ${list[i].address}'),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: <Widget>[
                      auth.features['BUTTON_DELETE_ORDER'] != null
                          ? Icon(Icons.delete_forever)
                          : SizedBox(
                              width: 2,
                            ), // icon-2
                    ],
                  ),
                ),
              ),
              onRefresh: refreshList)
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.shifting,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_1),
            title: Text("Paid"),
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_2),
            title: Text("Ready"),
            backgroundColor: Colors.yellow[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_3),
            title: Text("Sent"),
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_4),
            title: Text("Received"),
            backgroundColor: Colors.blue,
          )
        ],
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
