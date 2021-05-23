import 'dart:html';

import 'package:flutter/material.dart';

import 'Widgets.dart';

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
    required this.verifyEmail,
    required this.signInWithEmailAndPassword,
    required this.cancelRegistration,
    required this.registerWithEmailAndPassword,
    required this.signOut,
  });

  final LoginState loginState;
  String? email;
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
  final void Function() cancelRegistration;
  final void Function(
    String email,
    String displayName,
    String password,
    void Function(Exception e) error,
  ) registerWithEmailAndPassword;
  final void Function() signOut;

  @override
  Widget build(BuildContext buildContext) {}

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
