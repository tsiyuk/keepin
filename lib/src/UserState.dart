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

  void startChangePassword() {
    _loginState = LoginState.forgetPassword;
    notifyListeners();
  }

  void verifyEmail(
    String email,
  ) async {
    User user = FirebaseAuth.instance.currentUser!;
    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
    //void signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _loginState = LoginState.loggedIn;
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<UserCredential> registerAccount(
    //void registerAccount(
    String email,
    String displayName,
    String password,
  ) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateProfile(displayName: displayName);
      _loginState = LoginState.loggedIn;
      notifyListeners();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e;
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
    final GoogleSignInAccount googleUser = (await GoogleSignIn().signIn())!;

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

  void resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    _loginState = LoginState.loggedOut;
  }

  void cancel() {
    _loginState = LoginState.loggedOut;
    notifyListeners();
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
    _loginState = LoginState.loggedOut;
    notifyListeners();
  }
}
