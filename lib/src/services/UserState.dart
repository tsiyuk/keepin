import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum LoginState {
  loggedOut,
  register,
  logInWithEmail,
  forgetPassword,
  loggedIn,
}

/*
  The UserState class handles the backend log in and register workflow with firebase
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

  User? _user;
  User? get user => _user;

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

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = credential.user;
      if (_user!.emailVerified) {
        _loginState = LoginState.loggedIn;
        notifyListeners();
      } else {
        _user!.delete();
        throw FirebaseAuthException(code: 'The user has not been verified!');
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  Future<UserCredential> registerAccount(
    String email,
    String displayName,
    String password,
  ) async {
    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = credential.user!;
      await user.sendEmailVerification();
      Timer.periodic(Duration(seconds: 3), (timer) async {
        user = FirebaseAuth.instance.currentUser!;
        await user.reload();
        if (user.emailVerified) {
          timer.cancel();
          await user.updateDisplayName(displayName);
          _loginState = LoginState.loggedIn;
          _user = user;
          notifyListeners();
        }
      });
      return credential;
    } on FirebaseAuthException catch (e) {
      throw e;
    }
  }

  void signInWithGoogle() async {
    final GoogleSignInAccount googleUser = (await GoogleSignIn().signIn())!;
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    var temp = await FirebaseAuth.instance.signInWithCredential(credential);
    _user = temp.user;
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
