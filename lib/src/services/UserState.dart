import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';

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

  // TODO: implement email verification
  Future<bool> verifyEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    bool flag = false;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
      // Timer timer = Timer.periodic(Duration(seconds: 100), (timer) async {
      //   await user.reload();
      //   if (user.emailVerified) {
      //     timer.cancel();
      //     flag = true;
      //   }
      // });
      // return timer.isActive ? false : true;
      // while (!user.emailVerified) {
      //   await user.reload();
      //   flag = user.emailVerified;
      // }
      return true;
    } else {
      return true;
    }
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
      _loginState = LoginState.loggedIn;
      notifyListeners();
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
      //bool flag = await verifyEmail();
      if (true) {
        await credential.user!.updateProfile(displayName: displayName);
        _loginState = LoginState.loggedIn;
        _user = credential.user!;
        FirestoreService firestoreService = FirestoreService();
        await firestoreService
            .setUserProfile(UserProfile(_user!.uid, displayName));
        notifyListeners();
      } else {
        //credential.user!.delete();
        print('verification fail');
      }
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
