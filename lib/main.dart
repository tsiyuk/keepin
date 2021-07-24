import 'package:flutter/material.dart';
import 'package:keepin/pages/StartPage.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
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
      ChangeNotifierProvider(
        create: (context) => PostProvider(),
      ),
      ChangeNotifierProvider(create: (context) => CircleProvider()),
      ChangeNotifierProvider(create: (context) => ChatRoomProvider()),
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
        primaryColorDark: Color(0xff104028),
        primaryColor: Color(0xff287050),
        primaryColorLight: Color(0xff66b088),
        // primaryColorLight: Color(0xffE4EFE7),
      ),
      home: StartPage(),
    );
  }
}
