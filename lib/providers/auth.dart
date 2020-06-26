import 'dart:convert';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:piratebay/models/user.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  final String _userPath = "http://10.0.2.2:8008/api/v1/user";
  final String _securityPath = 'http://10.0.2.2:8008/api/v1/security';

  Map<String, dynamic> features = new Map();
  User user;

  DateTime _refreshExpiryDate;
  DateTime _authExpiryDate;

  String _userId;
  Timer _authTimer;
  String _refreshToken;
  String _authToken;

  bool get isAuth {
    return userId != null;
  }

  String get userId {
    return _userId;
  }

  String get authToken {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return _authToken;
  }

  Future<void> login(String username, String password) async {
    return _authenticate(username, password);
  }

  Future<void> _authenticate(String username, String password) async {
    final resource = 'login';
    final url = '$_securityPath/$resource';
    username = username.trim();
    password = password.trim();
    print("User logging in...");
    try {
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
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
      print("User logged in.");
      await updateTokens(
          responseData['refresh'], responseData['authentication']);
      notifyListeners();
      // user = new User("asdasd","asdasd","asdasd","asdasd");
    } catch (error) {
      throw error;
    }
  }

  Future<void> _refreshTokens() async {
    final resource = 'refresh';
    final url = '$_securityPath/$resource';

    try {
      final response = await http.post(
        url,
        headers: {'content-type': 'application/json'},
        body: json.encode(
          {
            'refreshToken': _refreshToken,
          },
        ),
      );

      final responseData = json.decode(response.body);
      // final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw HttpException(responseData['message']);
      }
      print("Tokens refreshed.");
      await updateTokens(
          responseData['refresh'], responseData['authentication']);
      notifyListeners();
      // user = new User("asdasd","asdasd","asdasd","asdasd");
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateTokens(refreshToken, authToken) async {
    _refreshToken = refreshToken;
    _authToken = authToken;

    final refreshTokenPayload = Jwt.parseJwt(refreshToken);
    final authTokenPayload = Jwt.parseJwt(authToken);
    _userId = authTokenPayload['sub'];

    authTokenPayload['features'].forEach((value) {
      features[value] = value;
    });

    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(
      {
        'userId': _userId,
        'refreshToken': _refreshToken,
        'refreshExpireDate': refreshTokenPayload['exp'],
        'authToken': _authToken,
        'authExpireDate': authTokenPayload['exp']
      },
    );
    prefs.setString('userData', userData);
    _refreshExpiryDate =
        DateTime.fromMillisecondsSinceEpoch(refreshTokenPayload['exp'] * 1000);
    _authExpiryDate =
        DateTime.fromMillisecondsSinceEpoch(authTokenPayload['exp'] * 1000);

    _autoLogout();
    user = await getUserById(_userId);
    print("User ${user.username} just signed in.");
    print("Refresh token: $_refreshToken");
    print("Auth token: $_authToken");
  }

  // Future<void> signup(String username, String password) async {
  //   return _authenticate(username, password, 'signup');
  // }

  Future<bool> tryAutoLogin() async {
    // await logout();
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, dynamic>;
    _refreshToken = extractedUserData['refreshToken'];
    _authToken = extractedUserData['authToken'];
    _refreshExpiryDate = DateTime.fromMillisecondsSinceEpoch(
        extractedUserData['refreshExpireDate'] * 1000);
    _authExpiryDate = DateTime.fromMillisecondsSinceEpoch(
        extractedUserData['authExpireDate'] * 1000);
    _userId = extractedUserData['userId'];

    _autoLogout();
    final authTokenPayload = Jwt.parseJwt(_authToken);
    _userId = authTokenPayload['sub'];

    authTokenPayload['features'].forEach((value) {
      features[value] = value;
    });
    user = await getUserById(_userId);
    print('User has just reopened app.');
    print('Last user data:');
    print(extractedUserData);
    notifyListeners();
    // _autoLogout();
    return true;
  }

  Future<void> logout() async {
    // _token = null;
    print('User is logging out as id $_userId');
    _userId = null;
    features.clear();
    features = new Map();
    // _expiryDate = null;

    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry =
        _refreshExpiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }

  Future<dynamic> getUserById(String userId) async {
    bool session = await checkAuthToken();
    if (session) {
      try {
        final url = '$_userPath/$userId';
        final response = await http.get(url, headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        });
        return userFromJson(response.body);
      } catch (error) {
        throw error;
      }
    } else {
      return null;
    }
  }

  Future<bool> checkAuthToken() async {
    if (!_refreshExpiryDate.isAfter(DateTime.now())) {
      print("Unrefreshable token.");
      return false;
    } else if (!_authExpiryDate.isAfter(DateTime.now())) {
      print("Refreshing tokens.");
      await _refreshTokens();
      return true;
    } else {
      return true;
    }
  }

  Future<dynamic> getAllActiveUsers() async {
    print("Trying to get all active users");
    bool session = await checkAuthToken();
    if (session) {
      try {
        final url = '$_userPath/';
        final response = await http.get(url, headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        });

        List<dynamic> users = json.decode(response.body);
        print("Successfully got all active users.");
        return users;
        // return userFromJson(response.body);
      } catch (error) {
        throw error;
      }
    } else {
      return null;
    }
  }
}
