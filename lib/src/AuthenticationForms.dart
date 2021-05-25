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
        final userState = Provider.of<UserState>(context);
        userState.verifyEmail(_emailController.text, (e) { });
        userState.signInWithEmailAndPassword(_emailController.text, _passwordController.text, (e) { });
        // String userId = await userState.signInWithEmailAndPassword(
        //   _emailController.text,
        //   _passwordController.text,
        // );
        // print('Signed in $userId');
      } catch (e) {
        print(e);
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
              FormHelpers.buildTextFields(_emailController, _passwordController),
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
        userState.registerAccount(
            _emailController.text,
            _passwordController.text,
            _userNameController.text,
                (e) { });
        // print("sign up success");
      } catch (e) {
        print(e);
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
                FormHelpers.buildTextFields(_emailController, _passwordController, _userNameController),
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
            child: Text(
              "or log in with:"
            ),
          ),
          MaterialButton(
            onPressed: userState.signInWithGoogle,
            // color: Theme.of(buildContext).primaryColorLight,
            color: Colors.white,
            child: Image.asset(
              "assets/images/google-logo.png",
              height: 40.0
            ),
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
      return value == null || value.isEmpty ? "Please enter your $field." : null;
    };
  }

  static Padding buildTextFields(TextEditingController emailController, TextEditingController passwordController, [TextEditingController? nameController]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'email'),
            validator: FormHelpers.validator("email"),
          ),
          if ( nameController != null )
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'user name'),
              validator: FormHelpers.validator("user name"),
            ),
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