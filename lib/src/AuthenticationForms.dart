import 'package:flutter/material.dart';
import 'package:keepin/src/UserState.dart';
import 'package:provider/provider.dart';
import 'CommonWidgets.dart';

class EmailPasswordForm extends StatefulWidget {
  @override
  _EmailPasswordState createState() => _EmailPasswordState();
}

class _EmailPasswordState extends State<EmailPasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailPasswordFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext buildContext) {
    UserState userState = Provider.of<UserState>(buildContext);
    return Center(
      child: Column(children: [
        Image.asset("assets/images/TextLogoPrimary.png"),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your email address';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'password'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  SecondaryButton(
                    onPressed: userState.cancel,
                    child: Text('CANCEL'),
                  ),
                  SizedBox(width: 16),
                  PrimaryButton(
                    onPressed: () {
                      //if (_formKey.currentState!.validate()) {
                      userState.verifyEmail(_emailController.text, (e) { });
                      userState.signInWithEmailAndPassword(_emailController.text, _passwordController.text, (e) { });
                    },
                    child: Text('SIGN IN'),
                  ),
                  SizedBox(width: 30),
                ]))
            ],
          ),
        )
      ]),
    );
  }
}

class RegisterForm extends StatefulWidget {
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterFormState');
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext buildContext) {
    UserState userState = Provider.of<UserState>(buildContext);
    return Center(
      child: Column(children: [
        Header('Sign up with email'),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: 'Enter your email'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _userNameController,
                    decoration:
                        InputDecoration(hintText: 'Enter your user name'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your user name';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration:
                        InputDecoration(hintText: 'Enter your password'),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: userState.cancel,
                        child: Text('CANCEL'),
                      ),
                      SizedBox(width: 16),
                      PrimaryButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            userState.registerAccount(
                                _emailController.text,
                                _userNameController.text,
                                _passwordController.text,
                                (e){}
                            );
                          }
                        },
                        child: Text('SIGN UP'),
                      ),
                      SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class LogInMethods extends StatelessWidget {
  LogInMethods({
    required this.startLoginWithEmail,
    required this.startRegister,
    required this.startLoginWithGoogle,
  });
  final void Function() startLoginWithEmail;
  final void Function() startRegister;
  final void Function() startLoginWithGoogle;

  Padding buildLogInMethod(
      String text, IconData icon, void Function() onpress) {
    return Padding(
        padding: EdgeInsets.all(10.0),
        child: PrimaryButton(
          onPressed: onpress,
          child: Row(
            children: [
              Icon(icon),
              Text(text),
            ],
          ),
        ));
  }

  Widget build(BuildContext buildContext) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildLogInMethod(
              'Sign in with email', Icons.email_outlined, startLoginWithEmail),
          buildLogInMethod(
              'Sign up with email', Icons.app_registration, startRegister),
          // TODO: google icon
          buildLogInMethod('Sign in with google', Icons.android_outlined,
              startLoginWithGoogle),
        ],
      ),
    );
  }
}
