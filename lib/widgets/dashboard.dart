import 'package:flutter/material.dart';
import 'package:piratebay/providers/auth.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  double _verticalSpace = 20;
  double _horizontalSpace = 100;

  @override
  Widget build(BuildContext context) {
    Auth auth = Provider.of<Auth>(context, listen: false);


    return Padding(
      padding: EdgeInsets.all(_verticalSpace),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 50.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              auth.features['PAGE_USER_MANAGEMENT'] != null ? _menuButton(_verticalSpace, 'assets/buttons/manage_users.png',
                  '/manage/user', context) : Container(),
              auth.features['PAGE_PRODUCT_MANAGEMENT'] != null ? _menuButton(_verticalSpace, 'assets/buttons/manage_products.png',
                  '/products', context) : Container(),
              _logoutButton(
                  _verticalSpace, 'assets/buttons/log_out.png', context),
            ],
          ),
        ),
      ),
    );

    // Center(
    //   child: FlatButton(
    //     onPressed: () {
    //       //if in drawer I likey use
    //       // Navigator.of(context).pop();
    //       Navigator.of(context).pushReplacementNamed('/');
    //       Provider.of<Auth>(context, listen: false).logout();
    //     },
    //     child: Text('Log out'),
    //   ),
    // );
  }

  Widget _menuButton(
      double verticalSpace, String _path, String _page, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: verticalSpace),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, _page);
        },
        child: Image(
          image: AssetImage(_path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _logoutButton(
      double verticalSpace, String _path, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: verticalSpace, left: _horizontalSpace, right: _horizontalSpace),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacementNamed('/');
          Provider.of<Auth>(context, listen: false).logout();
        },
        child: Image(
          image: AssetImage(_path),
          height: _path == 'logout' ? 50 : null,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
