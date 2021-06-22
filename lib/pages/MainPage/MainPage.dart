import 'package:flutter/material.dart';
import 'package:keepin/pages/MainPage/HomePage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/services/UserState.dart';
import 'package:provider/provider.dart';

import 'UserProfilePage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context, listen: false);
    List<Widget> _subPages = <Widget>[
      // TODO to add sub-pages
      HomePage(),
      Text('Discover'),
      Text('Messages'),
      // assume that the user has logged in
      UserProfilePage(userState.user!),
      // PrimaryButton(onPressed: userState.signOut, child: Text("Sign out")),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bar'),
      ),
      body: Center(
        child: _subPages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.visibility_outlined),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.blueGrey,
        onTap: _onItemTapped,
      ),
    );
  }
}
