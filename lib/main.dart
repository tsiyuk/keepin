import 'package:flutter/material.dart';
import 'package:keepin/pages/StartPage.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:keepin/src/services/UserState.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => UserState(),
      ),
      ChangeNotifierProvider(
        create: (context) => UserProfileProvider(),
      ),
    ],
    builder: (context, child) => MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'keepin sketch',
      theme: ThemeData(
        primaryColorDark: Color(0xff0B4229),
        primaryColor: Color(0xff115c45),
        primaryColorLight: Color(0xc0248F7D),
      ),
      home: StartPage(),
    );
  }
}
