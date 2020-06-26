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
  List<Order> ordersList = [];
  List<Order> filteredOrdersList = [];

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

    if (ordersList != null) {
      // print(listAux);
      // setState(() {
        ordersList = listAux;
      // });
      filterOrders();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void filterOrders() {
    List<Order> filteredAuxList = [];

    ordersList.forEach(
      (element) {
        if (_currentIndex == 0) {
          if (element.orderStatus == "paid") {
            filteredAuxList.add(element);
          }
        }else if (_currentIndex == 1) {
          if (element.orderStatus == "prepared") {
            filteredAuxList.add(element);
          }
        }else if (_currentIndex == 2) {
          if (element.orderStatus == "shipped") {
            filteredAuxList.add(element);
          }
        }else if (_currentIndex == 3) {
          if (element.orderStatus == "delivered") {
            filteredAuxList.add(element);
          }
        }
      },
    );

    setState(() {
      filteredOrdersList = filteredAuxList;
    });
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<Auth>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Active Orders"),
      ),
      body: ordersList.length != 0
          ? RefreshIndicator(
              // key: refreshKey,
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                ),
                itemCount: filteredOrdersList.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text('Order Id: ${filteredOrdersList[i].orderId}'),
                  // subtitle: Text('Username: ${list[i]['username']}'),
                  subtitle: Column(
                    children: <Widget>[
                      Text(
                          'Date: ${DateFormat.yMEd().add_jms().format(DateTime.parse(filteredOrdersList[i].orderDate))}'),
                      Text('Client: ${filteredOrdersList[i].userOrder.username}'),
                      Text('Addres: ${filteredOrdersList[i].address}'),
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
            title: Text("Prepared"),
            backgroundColor: Colors.yellow[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_3),
            title: Text("Shipped"),
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_4),
            title: Text("Delivered"),
            backgroundColor: Colors.blue,
          )
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          filterOrders();
        },
      ),
    );
  }
}
