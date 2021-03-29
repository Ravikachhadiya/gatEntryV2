import '../screens/approval_request_screen.dart';
import '../screens/house_number_screen.dart';
import '../widgets/security_guard_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../providers/user.dart';
import '../screens/login_and_signup_screen.dart';
import '../screens/building_screen.dart';

class AppDrawer extends StatelessWidget {
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      prefs.clear();
      Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
    } catch (e) {
      //print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = Provider.of<User>(context, listen: false).userInfo;
    final address = Provider.of<User>(context, listen: false).userAddress;
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: userInfo.userType != UserType.SecurityGuard
                ? Text(userInfo.name)
                : Text(address[1]),
            automaticallyImplyLeading: false,
          ),
          userInfo.userType == UserType.HigherAuthority
              ? Column(
                  children: <Widget>[
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.approval),
                      title: Text('Approval Request'),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(ApprovalRequestScreen.routeName);
                      },
                    ),
                  ],
                )
              : Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () {
              Navigator.of(context).pop();
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
