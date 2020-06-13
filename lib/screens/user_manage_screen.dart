import 'dart:async';
import 'package:flutter/material.dart';
import 'package:piratebay/providers/auth.dart';
import 'package:provider/provider.dart';

class UserManageScreen extends StatefulWidget {
  @override
  _UserManageScreenState createState() => new _UserManageScreenState();
}

class _UserManageScreenState extends State<UserManageScreen> {
  List<dynamic> list = [];
  var random;
  // var refreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> refreshKey =
      new GlobalKey<RefreshIndicatorState>();
  Auth auth;

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
    auth = Provider.of<Auth>(context, listen: false);
    var listAux = await auth.getAllActiveUsers();

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Active Users"),
      ),
      body: list.length != 0
          ? RefreshIndicator(
              // key: refreshKey,
              child: ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text('User Id: ${list[i]['userId']}'),
                  // subtitle: Text('Username: ${list[i]['username']}'),
                  subtitle: Column(
                    children: <Widget>[
                      Text('Username: ${list[i]['username']}'),
                      Text('Email: ${list[i]['email']}'),
                      Text('Phone: ${list[i]['phoneNumber']}'),
                    ],
                  ),
                  trailing: Wrap(
                    spacing: 12, // space between two icons
                    children: <Widget>[
                      Icon(Icons.edit), // icon-1
                      auth.features['BUTTON_DELETE_USER'] != null
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
    );
  }
}
