import 'dart:convert';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  // String _token;
  // DateTime _expiryDate;
  int _userId;
  Timer _authTimer;

  bool get isAuth {
    return userId != null;
  }

  // String get token {
    // if (_expiryDate != null &&
    //     _expiryDate.isAfter(DateTime.now()) &&
    //     _token != null) {
    //   return _token;
    // }
  //   return null;
  // }

  int get userId {
    return _userId;
  }

  Future<void> _authenticate(
    String username, String password, String urlSegment) async {
    
    final url = 'http://10.0.2.2:8008/api/v1/security/$urlSegment';
    username = username.trim();
    password = password.trim();
    try {
      final response = await http.post(
        url,
        headers: {
          'content-type': 'application/json'
        },
        body: json.encode(
          {
            'username': username,
            'password': password,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        throw HttpException(responseData['message']);
      }
      // _token = responseData['idToken'];
      _userId = responseData['userId'];
      // _expiryDate = DateTime.now().add(
      //   Duration(
      //     seconds: int.parse(
      //       responseData['expiresIn'],
      //     ),
      //   ),
      // );
      // _autoLogout();
      print('User is $urlSegment as id $_userId');
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          // 'token': _token,
          'userId': _userId,
          // 'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String username, String password) async {
    return _authenticate(username, password, 'signup');
  }

  Future<void> login(String username, String password) async {
    return _authenticate(username, password, 'login');
  }

  Future<bool> tryAutoLogin() async {
    // await logout();
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    // final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    // if (expiryDate.isBefore(DateTime.now())) {
    //   return false;
    // }
    // _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    print('User is saved as id $_userId');
    // _expiryDate = expiryDate;
    notifyListeners();
    // _autoLogout();
    return true;
  }

  Future<void> logout() async {
    // _token = null;
    print('User is logging out as id $_userId');
    _userId = null;
    // _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  // void _autoLogout() {
  //   if (_authTimer != null) {
  //     _authTimer.cancel();
  //   }
  //   final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
  //   _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  // }
}
