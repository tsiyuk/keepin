import 'package:flutter/material.dart';
import 'package:keepin/pages/StartPage.dart';
import 'package:keepin/src/UserState.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserState(),
      builder: (context, _) => MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'keepin sketch',
      theme: ThemeData(
        primaryColorDark: Color(0xff0B4229),
        primaryColor: Color(0xff115c45),
        primaryColorLight: Color(0xff248F7D),
      ),
      home: StartPage(),
    );
  }
}
