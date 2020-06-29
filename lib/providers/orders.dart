import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:piratebay/models/order.dart';
import 'package:piratebay/models/productOrder.dart';
import 'package:piratebay/providers/auth.dart';

class Orders with ChangeNotifier {
  Auth _auth;

  void update(Auth auth) {
    _auth = auth;
  }

  // Orders(this.auth);
  final String _orderPath = 'http://10.0.2.2:8008/api/v1/order';

  Order _chosenOrder;

  Order get chosenOrder => _chosenOrder;

  set chosenOrder(Order chosenOrder) {
    _chosenOrder = chosenOrder;
  }

  Future<List<Order>> getAllOrders() async {
    bool session = await _auth.checkAuthToken();

    if (session) {
      try {
        var url = '$_orderPath/';
        String authToken = _auth.authToken;
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        );

        final List<Order> loadedOrders = [];
        final List<dynamic> extractedData = json.decode(response.body);
        // print(extractedData);
        extractedData.forEach((data) {
          Order newOrder = orderFromJson(json.encode(data));
          loadedOrders.add(newOrder);
        });

        return loadedOrders;
      } catch (error) {
        throw (error);
      }
    } else {
      return null;
    }
  }

  Future<List<ProductOrder>> getOrderProducts(int orderId) async {
    bool session = await _auth.checkAuthToken();

    if (session) {
      try {
        var url = '$_orderPath/$orderId/product';
        String authToken = _auth.authToken;
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        );

        final List<ProductOrder> loadedProductOrders = [];
        final List<dynamic> extractedData = json.decode(response.body);
        // print(extractedData);
        extractedData.forEach((data) {
          ProductOrder newOrder = productOrderFromJson(json.encode(data));
          loadedProductOrders.add(newOrder);
        });
        // notifyListeners();
        // print("-----------------");
        // print(extractedData);
        // print("-----------------");
        // print(extractedData[0]);
        // print("-----------------");
        return loadedProductOrders;
      } catch (error) {
        print("error in getOrderProducts");
        throw (error);
      }
    } else {
      return null;
    }
  }

  Future<dynamic> updateOrderProductQty(
      int orderId, int productOrderId, int qttyCommit, int qttyReceived) async {
    bool session = await _auth.checkAuthToken();

    if (session) {
      try {
        var url = '$_orderPath/$orderId/product';
        String authToken = _auth.authToken;
        final response = await http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'content-type': 'application/json',
          },
          body: json.encode(
            {
              'productOrderId': productOrderId,
              'qttyCommit': qttyCommit,
              'qttyReceived': qttyReceived
            },
          ),
        );

        final extractedData = json.decode(response.body);
        print("-----------------");
        print(extractedData);
        return extractedData;
      } catch (error) {
        print("error in updateOrderProductQty");
        print(error);
        throw (error);
      }
    } else {
      return null;
    }
  }

  // http://localhost:8008/api/v1/order/1
  Future<dynamic> updateOrderStatus(int orderId, String orderStatus) async {
    bool session = await _auth.checkAuthToken();

    if (session) {
      try {
        var url = '$_orderPath/$orderId';
        String authToken = _auth.authToken;
        final response = await http.patch(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'content-type': 'application/json',
          },
          body: json.encode(
            {
              'orderStatus': orderStatus,
            },
          ),
        );

        final extractedData = json.decode(response.body);
        print("-----------------");
        print(extractedData);
        return extractedData;
      } catch (error) {
        print("error in updateOrderStatus");
        print(error);
        throw (error);
      }
    } else {
      return null;
    }
  }

    Future<dynamic> deleteOrder(int orderId) async {
    bool session = await _auth.checkAuthToken();

    if (session) {
      try {
        var url = '$_orderPath/$orderId';
        String authToken = _auth.authToken;
        final response = await http.delete(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
            'content-type': 'application/json',
          }
        );

        final extractedData = json.decode(response.body);
        print("-----------------");
        print(extractedData);
        return extractedData;
      } catch (error) {
        print("error in deleteOrder");
        print(error);
        throw (error);
      }
    } else {
      return null;
    }
  }
}
