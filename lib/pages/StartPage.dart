import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:keepin/src/Authentication.dart';

class StartPage extends StatelessWidget {
  StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign in or Sign up"),
        ),
        body: Authentication());
  }
}
