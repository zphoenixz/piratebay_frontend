import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:piratebay/models/order.dart';
import 'package:piratebay/providers/auth.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Orders with ChangeNotifier {
  final Auth auth;

  Orders(this.auth);
  final String _orderPath = 'http://10.0.2.2:8008/api/v1/order';

  Future<List<Order>> fetchAndSetOrders() async {
    bool session = await auth.checkAuthToken();

    if (session) {
      try {
        var url = '$_orderPath/';
        String authToken = auth.authToken;
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        );

        final List<Order> loadedOrders = [];
        final List<dynamic> extractedData = json.decode(response.body);
        print(extractedData);
        extractedData.forEach((data) {
          Order newOrder = orderFromJson(json.encode(data));
          loadedOrders.add(newOrder);
        });
        // notifyListeners();
        // print("-----------------");
        // print(extractedData);
        // print("-----------------");
        // print(extractedData[1]);
        // print("-----------------");
        return loadedOrders;
      } catch (error) {
        throw (error);
      }
    } else {
      return null;
    }
  }
}
