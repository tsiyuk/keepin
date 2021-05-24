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
        return LogInMethods(
          startLoginWithEmail: userState.startLoginWithEmail,
          startRegister: userState.startRegister,
          signInWithGoogle: userState.signInWithGoogle,
        );
      case LoginState.logInWithEmail:
        return EmailPasswordForm(
          verifyEmailandPassword: (email, password) =>
              userState.signInWithEmailAndPassword(
                  email,
                  password,
                  (e) =>
                      _showErrorDialog(buildContext, 'Failed to sign in', e)),
          cancel: userState.cancel,
        );
      case LoginState.register:
        return RegisterForm(
            registerAccount: (email, username, password) =>
                userState.registerAccount(
                    email,
                    username,
                    password,
                    (e) => _showErrorDialog(
                        buildContext, 'Failed to create account', e)),
            cancel: userState.cancel);
      // TODO
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
            StyledButton(
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
