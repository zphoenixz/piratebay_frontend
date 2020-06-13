import 'package:flutter/material.dart';
import 'package:piratebay/models/user.dart';
import 'package:piratebay/providers/auth.dart';
import 'package:piratebay/widgets/dashboard.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenScreenState createState() => _HomeScreenScreenState();
}

class _HomeScreenScreenState extends State<HomeScreen> {
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);
    User user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: new RichText(
          text: new TextSpan(
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: new TextStyle(
              fontSize: 20.0,
            ),
            children: <TextSpan>[
              new TextSpan(text: 'Welcome back, '),
              new TextSpan(
                  text: '${user.username}!',
                  style: new TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Dashboard(),
    );
  }
}
