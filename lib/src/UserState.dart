// @dart=2.9
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/Authentication.dart';
import 'package:google_sign_in/google_sign_in.dart';

/*
  The UserState class will handle all the program related to Firebase
*/
class UserState extends ChangeNotifier {
  UserState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();
  }

  LoginState _loginState = LoginState.loggedOut;
  LoginState get loginState => _loginState;

  // methods related to log in

  void startLoginWithEmail() {
    _loginState = LoginState.logInWithEmail;
    notifyListeners();
  }

  void startRegister() {
    _loginState = LoginState.register;
    notifyListeners();
  }

  // void verifyEmail(
  //   String email,
  //   void Function(FirebaseException e) errorCallback,
  // ) async {
  //   try {
  //     var methods =
  //         await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
  //     if (!methods.contains('password')) {
  //       _loginState = LoginState.register;
  //     }
  //     notifyListeners();
  //   } on FirebaseAuthException catch (e) {
  //     errorCallback(e);
  //   }
  // }

  //Future<UserCredential>? signInWithEmailAndPassword(
  void signInWithEmailAndPassword(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _loginState = LoginState.loggedIn;
      notifyListeners();
      //return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _loginState = LoginState.register;
      }
      errorCallback(e);
    }
  }

  //Future<UserCredential> registerAccount(
  void registerAccount(String email, String displayName, String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user.updateProfile(displayName: displayName);
      _loginState = LoginState.loggedIn;
      notifyListeners();
      //return credential;
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  //Future<UserCredential> signInWithGoogle
  // void signInWithGoogle(
  //     void Function(FirebaseAuthException e) errorCallback) async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser.authentication;

  //   // Create a new credential
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );

  //   // Once signed in, return the UserCredential
  //   try {
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //   } on FirebaseAuthException catch (e) {
  //     errorCallback(e);
  //   }
  // }

  void signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
    _loginState = LoginState.loggedIn;
    notifyListeners();
  }

  void cancel() {
    _loginState = LoginState.loggedOut;
    notifyListeners();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }
}
