import 'dart:math';

import './providers/approval_request.dart';
import './screens/approval_request_screen.dart';
import './widgets/security_guard_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/home_screen.dart';
import './providers/person_entry.dart';
import './screens/edit_person_entry_screen.dart';
import './screens/edit_profile_screen.dart';
import './screens/history_details_screen.dart';
import './screens/tab_screen.dart';
import './screens/login_and_signup_screen.dart';
// import './widgets/auth_widget_check.dart';
import './providers/user.dart';
import './screens/signup_screen.dart';
import './screens/profile_screen.dart';
import './screens/building_screen.dart';
import './screens/house_number_screen.dart';

void main() {
  runApp(MyApp());
}

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);

class GreenMainTheme {
  static const Color primary = Color(0xff0DAA1D);
}

class MyApp extends StatelessWidget {
  static const routeName = 'main-screen';
  // This widget is the root of your application.

  Widget loader() {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(
            Color(0xff0DAA1D),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: PersonsEntries(),
        ),
        ChangeNotifierProvider<User>(
          create: (context) => User(),
        ),
        ChangeNotifierProvider<ApprovalRequest>(
          create: (context) => ApprovalRequest(),
        ),
      ],
      child: Consumer<User>(
        builder: (ctx, user, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GatEntry',
          theme: ThemeData(
            primarySwatch: generateMaterialColor(GreenMainTheme.primary),
            primaryColor: Color(0xff0DAA1D),
            accentColor: Color(0xff421818),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            backgroundColor: Colors.white,
          ),
          home: user.isUser
              ? TabScreen()
              : FutureBuilder(
                  future: user.tryAutoLogin(),
                  builder: (context, snapshot) {
                    //print("SnapShot data 1 : " + snapshot.data.toString());
                    //print("userIdOfUser 1 : " + user.userIdOfUser.toString());
                    return snapshot.data == null
                        ? loader()
                        : user.userIdOfUser == null
                            ? LoginPage()
                            : FutureBuilder(
                                future: user.isUserNew(user.userIdOfUser),
                                builder: (context, usersnapshot) {
                                  //print("userSnapShot : " + usersnapshot.data.toString());
                                  //print("userIdOfUser : " + user.userIdOfUser.toString());
                                  return (usersnapshot.hasError)
                                      ? loader()
                                      : usersnapshot.data == null
                                          ? loader()
                                          : usersnapshot.data
                                              ? SignupScreen()
                                              : LoginPage();
                                },
                              );
                  },
                ),
          routes: {
            HistoryDetailsScreen.routeName: (ctx) => HistoryDetailsScreen(),
            EditProfileScreen.routeName: (ctx) => EditProfileScreen(),
            HomeScreen.routeName: (ctx) => HomeScreen(),
            EditPersonEntryScreen.routeName: (ctx) => EditPersonEntryScreen(),
            LoginPage.routeName: (ctx) => LoginPage(),
            TabScreen.routeName: (ctx) => TabScreen(),
            MyApp.routeName: (ctx) => MyApp(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            BuildingScreen.routeName: (ctx) => BuildingScreen(),
            HouseNumberScreen.routeName: (ctx) => HouseNumberScreen(),
            ApprovalRequestScreen.routeName: (ctx) => ApprovalRequestScreen(),
            SecurityGuardWidget.routeName: (ctx) => SecurityGuardWidget(),
          },
        ),
      ),
    );
  }
}
