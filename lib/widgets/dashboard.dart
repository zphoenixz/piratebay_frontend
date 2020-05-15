import 'package:flutter/material.dart';
import 'package:piratebay/providers/auth.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FlatButton(
        onPressed: () {
          //if in drawer I likey use
          // Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/');
          Provider.of<Auth>(context, listen: false).logout();
        },
        child: Text('Log out'),
      ),
    );
  }
}
