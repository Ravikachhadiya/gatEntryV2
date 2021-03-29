import 'package:flutter/material.dart';
import '../screens/tab_screen.dart';
import '../screens/login_and_signup_screen.dart';
import '../providers/user.dart';
import 'package:provider/provider.dart';
import '../screens/signup_screen.dart';

class AuthWidgetCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (ctx, user, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: user.isUser
            ? TabScreen()
            : FutureBuilder(
                future: user.tryAutoLogin(),
                builder: (context, snapshot) {
                  //print("SnapShot data 1 : " + snapshot.data.toString());
                  //print("userIdOfUser 1 : " + user.userIdOfUser.toString());
                  return snapshot.data == null
                      ? Center(child: CircularProgressIndicator())
                      : user.userIdOfUser == null
                          ? LoginPage()
                          : FutureBuilder(
                              future: user.isUserNew(user.userIdOfUser),
                              builder: (context, usersnapshot) {
                                //print("userSnapShot : " + usersnapshot.data.toString());
                                //print("userIdOfUser : " + user.userIdOfUser.toString());
                                return (usersnapshot.hasError)
                                    ? Center(child: CircularProgressIndicator())
                                    : usersnapshot.data == null
                                        ? Center(
                                            child: CircularProgressIndicator())
                                        : usersnapshot.data
                                            ? SignupScreen()
                                            : LoginPage();
                              },
                            );
                },
              ),
      ),
    );
  }
}
