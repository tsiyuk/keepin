import 'package:flutter/material.dart';
import 'package:keepin/src/AuthenticationForms.dart';
import 'package:keepin/src/UserState.dart';
import 'package:provider/provider.dart';

import 'CommonWidgets.dart';

enum LoginState {
  loggedOut,
  register,
  logInWithEmail,
  forgetPassword,
  loggedIn,
}

class Authentication extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    UserState userState = Provider.of<UserState>(buildContext);
    switch (userState.loginState) {
      case LoginState.loggedOut:
        return LogInMethods();
      case LoginState.logInWithEmail:
        return EmailPasswordForm();
      case LoginState.register:
        return RegisterForm();
      case LoginState.loggedIn:
      case LoginState.forgetPassword:
      default:
        return Row(
          children: [
            Text("Emm, need more updates"),
          ],
        );
    }
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${(e as dynamic).message}',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            PrimaryButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.lightGreen),
              ),
            ),
          ],
        );
      },
    );
  }
}
