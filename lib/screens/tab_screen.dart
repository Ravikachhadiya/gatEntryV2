import '../screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screens/home_screen.dart';
import '../screens/history_details_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/app_drawer.dart';

class TabScreen extends StatefulWidget {
  static const routeName = 'tab-screen';

  @override
  _TabScreenState createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  List<Map<String, Object>> _pages;
  int _selectedPageIndex = 1;

  @override
  void initState() {
    _pages = [
      {
        'page': HistoryDetailsScreen(),
        'lable': 'History',
      },
      {
        'page': HomeScreen(),
        'lable': 'GatEntry',
      },
      {
        'page': ProfileScreen(),
        'lable': 'Profile',
      },
    ];
    super.initState();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    return Scaffold(
      appBar: _selectedPageIndex != 2
          ? AppBar(
              title: Text(_pages[_selectedPageIndex]['lable']),
            )
          : AppBar(
              title: Text(_pages[_selectedPageIndex]['lable']),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(EditProfileScreen.routeName),
                ),
              ],
            ),
      drawer: AppDrawer(),
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Theme.of(context).accentColor,
        currentIndex: _selectedPageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
