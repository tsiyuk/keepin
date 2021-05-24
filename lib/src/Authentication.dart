import 'package:flutter/material.dart';
import 'package:keepin/src/AuthenticationForms.dart';
import 'package:provider/provider.dart';
import 'CommonWidgets.dart';

enum LoginState {
  loggedOut,
  register,
  logInWithEmail,
  logInWithGoogle,
  forgetPassword,
  loggedIn,
}

class Authentication extends StatelessWidget {
  Authentication({
    required this.loginState,
    this.email,
    required this.startLoginWithEmail,
    required this.startRegister,
    required this.startLoginWithGoogle,
    required this.verifyEmail,
    required this.signInWithEmailAndPassword,
    required this.cancel,
    required this.registerWithEmailAndPassword,
    required this.signOut,
  });

  final LoginState loginState;
  final String? email;
  final void Function() startLoginWithEmail;
  final void Function() startRegister;
  final void Function() startLoginWithGoogle;
  final void Function(
    String email,
    void Function(Exception e) error,
  ) verifyEmail;
  final void Function(
    String email,
    String password,
    void Function(Exception e) error,
  ) signInWithEmailAndPassword;
  // TODO: signINWithGoogle
  final void Function() cancel;
  final void Function(
    String email,
    String displayName,
    String password,
    void Function(Exception e) error,
  ) registerWithEmailAndPassword;
  final void Function() signOut;

  @override
  Widget build(BuildContext buildContext) {
    switch (loginState) {
      case LoginState.loggedOut:
        return LogInMethods(
            startLoginWithEmail: startLoginWithEmail,
            startRegister: startRegister,
            startLoginWithGoogle: startLoginWithGoogle);
      case LoginState.logInWithEmail:
        return EmailPasswordForm();
      case LoginState.register:
        return RegisterForm();
      // TODO
      case LoginState.logInWithGoogle:
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
