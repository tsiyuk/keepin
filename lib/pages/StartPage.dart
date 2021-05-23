import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:keepin/src/UserState.dart';
import 'package:keepin/src/Authentication.dart';

class StartPage extends StatelessWidget {
  StartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign in or Sign up"),
      ),
      body: Consumer<UserState>(
        builder: (buildContext, userState, _) => Authentication(
            loginState: userState.loginState,
            startLoginWithEmail: userState.startLoginWithEmail,
            startRegister: userState.startRegister,
            startLoginWithGoogle: userState.startLoginWithGoogle,
            verifyEmail: userState.verifyEmail,
            signInWithEmailAndPassword: userState.signInWithEmailAndPassword,
            cancel: userState.cancel,
            registerWithEmailAndPassword: userState.registerAccount,
            signOut: userState.signOut),
      ),
    );
  }
}
