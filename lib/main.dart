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
        primaryColor: Colors.lightGreen,
      ),
      home: StartPage(),
    );
  }
}
