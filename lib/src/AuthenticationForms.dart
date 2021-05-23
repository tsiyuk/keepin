import 'package:flutter/material.dart';

import 'CommonWidgets.dart';

class EmailPasswordForm extends StatefulWidget {
  EmailPasswordForm({
    required this.verifyEmail,
    required this.verifyEmailandPassword,
    required this.cancel,
  });
  final void Function(String email) verifyEmail;
  final void Function(String email, String password) verifyEmailandPassword;
  final void Function() cancel;

  @override
  _EmailPasswordState createState() => _EmailPasswordState();
}

class _EmailPasswordState extends State<EmailPasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailPasswordFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext buildContext) {
    return Center(
      child: Column(children: [
        Header('Sign in with email'),
        Padding(
          padding: EdgeInsets.all(8.0),
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
                  controller: _passwordController,
                  decoration: InputDecoration(hintText: 'Enter your password'),
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
                  child:
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      onPressed: widget.cancel,
                      child: Text('CANCEL'),
                    ),
                    SizedBox(width: 16),
                    StyledButton(
                      onPressed: () {
                        //if (_formKey.currentState!.validate()) {
                        widget.verifyEmail(_emailController.text);
                        widget.verifyEmailandPassword(
                            _emailController.text, _passwordController.text);
                        //}
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
  RegisterForm({
    required this.email,
    required this.registerAccount,
    required this.cancel,
  });
  final String? email;
  final void Function(String email, String userName, String password)
      registerAccount;
  final void Function() cancel;
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
                        onPressed: widget.cancel,
                        child: Text('CANCEL'),
                      ),
                      SizedBox(width: 16),
                      StyledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.registerAccount(
                                _emailController.text,
                                _userNameController.text,
                                _passwordController.text);
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
        child: StyledButton(
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
