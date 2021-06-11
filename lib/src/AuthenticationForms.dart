import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/services/UserState.dart';
import 'package:provider/provider.dart';
import 'CommonWidgets.dart';

/*
  The authentication forms contains the layout of log in page.
  
*/

class EmailPasswordForm extends StatefulWidget {
  @override
  _EmailPasswordState createState() => _EmailPasswordState();
}

class _EmailPasswordState extends State<EmailPasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_EmailPasswordFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  bool validate() {
    final form = _formKey.currentState!;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      try {
        final userState = Provider.of<UserState>(context, listen: false);
        await userState.signInWithEmailAndPassword(
            _emailController.text, _passwordController.text);
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.code;
          print(_errorMessage);
        });
      }
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    UserState userState = Provider.of<UserState>(buildContext);
    return Center(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
          child: Image.asset("assets/images/TextLogoPrimary.png"),
        ),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FormHelpers.buildTextFields(_emailController,
                  passwordController: _passwordController),
              _errorMessage != null ? ErrorMessage(_errorMessage!) : SizedBox(),
              _buildSecondaryButtons(userState),
              PrimaryButton(
                onPressed: submit,
                child: Text('SIGN IN'),
              ),
            ],
          ),
        )
      ]),
    );
  }

  Padding _buildSecondaryButtons(UserState userState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SecondaryButton(
            onPressed: userState.startRegister,
            child: Text('Create an Account'),
          ),
          SecondaryButton(
            onPressed: userState.startChangePassword,
            child: Text('Forgot Password'),
          ),
        ],
      ),
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
  String? _errorMessage;

  bool validate() {
    final form = _formKey.currentState!;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      try {
        // print("sign up start");
        final userState = Provider.of<UserState>(context, listen: false);
        //userState.verifyEmail(_emailController.text);
        await userState.registerAccount(_emailController.text,
            _userNameController.text, _passwordController.text);
        // print("sign up success");
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.code;
        });
      }
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    UserState userState = Provider.of<UserState>(buildContext);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
            child: Image.asset("assets/images/TextLogoPrimary.png"),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FormHelpers.buildTextFields(_emailController,
                    passwordController: _passwordController,
                    nameController: _userNameController),
                _errorMessage != null
                    ? ErrorMessage(_errorMessage!)
                    : SizedBox(),
                _buildSecondaryButtons(userState),
                PrimaryButton(
                  onPressed: submit,
                  child: Text('SIGN UP'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding _buildSecondaryButtons(UserState userState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SecondaryButton(
            onPressed: userState.startLoginWithEmail,
            child: Text('Go to log in'),
          ),
          SecondaryButton(
            onPressed: userState.startChangePassword,
            child: Text('Forgot Password'),
          ),
        ],
      ),
    );
  }
}

class ForgetPasswordForm extends StatefulWidget {
  @override
  _ForgetPasswordFormState createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_ForgetPasswordFormState');
  final _emailController = TextEditingController();
  bool _isSubmit = false;
  String? _errorMessage;

  bool validate() {
    final form = _formKey.currentState!;
    form.save();
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void submit() async {
    if (validate()) {
      try {
        final userState = Provider.of<UserState>(context, listen: false);
        userState.resetPassword(_emailController.text);
        setState(() {
          _isSubmit = true;
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.code;
          // print(_errorMessage);
        });
      }
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    UserState userState = Provider.of<UserState>(buildContext);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
            child: Image.asset("assets/images/TextLogoPrimary.png"),
          ),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FormHelpers.buildTextFields(_emailController),
                PrimaryButton(
                  onPressed: submit,
                  child: Text('Reset password'),
                ),
                _errorMessage != null
                    ? ErrorMessage(_errorMessage!)
                    : SizedBox(),
                _isSubmit
                    ? Text(
                        'A reset password email has been sent',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Theme.of(buildContext).primaryColor),
                      )
                    : SizedBox(),
                _buildSecondaryButtons(userState),
              ],
            ),
          )
        ],
      ),
    );
  }

  Padding _buildSecondaryButtons(UserState userState) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SecondaryButton(
            onPressed: userState.startLoginWithEmail,
            child: Text('Go to log in'),
          ),
        ],
      ),
    );
  }
}

class LogInMethods extends StatelessWidget {
  Widget build(BuildContext buildContext) {
    UserState userState = Provider.of<UserState>(buildContext);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmailPasswordForm(),
          Divider(
            height: 40,
            thickness: 1,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text("or log in with:"),
          ),
          MaterialButton(
            onPressed: userState.signInWithGoogle,
            // color: Theme.of(buildContext).primaryColorLight,
            color: Colors.white,
            child: Image.asset("assets/images/google-logo.png", height: 40.0),
            padding: EdgeInsets.all(5.0),
            shape: CircleBorder(),
          ),
        ],
      ),
    );
  }
}

class FormHelpers {
  static String? Function(String?) validator(String field) {
    return (String? value) {
      return value == null || value.isEmpty
          ? "Please enter your $field."
          : null;
    };
  }

  static Padding buildTextFields(TextEditingController emailController,
      {TextEditingController? passwordController,
      TextEditingController? nameController}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'email'),
            validator: FormHelpers.validator("email"),
          ),
          if (nameController != null)
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'user name'),
              validator: FormHelpers.validator("user name"),
            ),
          if (passwordController != null)
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'password'),
              obscureText: true,
              validator: FormHelpers.validator("password"),
            ),
        ],
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  ErrorMessage(this._error);
  final String _error;

  Widget build(BuildContext buildContext) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Text(_error, style: TextStyle(color: Colors.red)));
  }
}
