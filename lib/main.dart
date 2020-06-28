// jperez 123456 Admin, puede hacer los 3
// jramiro 123456 Warehouse , no puede borrar orden

import 'package:flutter/material.dart';
import 'package:piratebay/providers/orders.dart';
import 'package:piratebay/screens/home.dart';
import 'package:piratebay/screens/order_details.dart';
import 'package:piratebay/screens/order_manage_screen.dart';
import 'package:piratebay/screens/user_manage_screen.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './providers/auth.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(),
          update: (_, auth, previousOrders) => 
          previousOrders..update(auth)
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'PirateBay',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Colors.blueAccent,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            // '/': (context) => FirstScreen(),
            '/manage/user': (ctx) => UserManageScreen(),
            '/manage/order': (ctx) => OrderManageScreen(),
            '/manage/order/detail': (ctx) => OrderDetailsScreen()
          },
        ),
      ),
    );
  }
}
