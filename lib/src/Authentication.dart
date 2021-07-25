import 'package:flutter/material.dart';
import 'package:keepin/pages/MainPage/MainPage.dart';
import 'package:keepin/src/AuthenticationForms.dart';
import 'package:keepin/src/services/UserState.dart';
import 'package:provider/provider.dart';

import 'CommonWidgets.dart';

class Authentication extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    UserState userState = Provider.of<UserState>(buildContext);
    switch (userState.loginState) {
      case LoginState.loggedOut:
      case LoginState.logInWithEmail:
        return LogInMethods();
      case LoginState.register:
        return RegisterForm();
      case LoginState.forgetPassword:
        return ForgetPasswordForm();
      case LoginState.loggedIn:
        return MainPage();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Emm, need more updates"),
              SecondaryButton(
                onPressed: userState.startLoginWithEmail,
                child: Text('Go to log in'),
              ),
            ],
          ),
        );
    }
  }
}
