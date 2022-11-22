import 'package:email_validator/email_validator.dart';
import 'package:flutter_chat_demo/home/view/home_view.dart';
import 'package:auth_service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../api/customer_controller.dart';
import '../../constants/app_constants.dart';
import '../../constants/color_constants.dart';
import '../../pages/home_page.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/background_widget.dart';
import '../../widgets/loading_view.dart';

class SignUpView extends StatefulWidget {
  SignUpView({Key? key}) : super(key: key);

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUpView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Status _status = Status.uninitialized;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: ColorConstants.primaryColor,
      ),
      body: Stack(children: <Widget>[
        backgroundWidget(),
        Container(
          height: double.infinity,
          alignment: Alignment.topCenter,
          child: Container(
              width: 200,
              height: 150,
              child: Image.asset('images/app_logo.png')),
        ),
        Center(
          child: DecoratedBox(
            decoration:
                const BoxDecoration(color: Color.fromARGB(143, 226, 226, 226)),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    direction: Axis.vertical,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      _CreateAccountEmail(emailController: _emailController),
                      const SizedBox(height: 30.0),
                      _CreateAccountPassword(
                          passwordController: _passwordController),
                      const SizedBox(height: 30.0),
                      _SubmitButton(
                        onStateChanged: (status) => setState(() {
                          _status = status;
                        }),
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                    ],
                  ),
                )),
          ),
        ),
        Positioned(
          child: _status == Status.authenticating
              ? LoadingView()
              : SizedBox.shrink(),
        )
      ]),
    );
  }
}

class _CreateAccountEmail extends StatelessWidget {
  _CreateAccountEmail({
    Key? key,
    required this.emailController,
  }) : super(key: key);
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(hintText: 'Email', errorMaxLines: 3),
        validator: (value) => EmailValidator.validate(value!)
            ? null
            : "Please enter a valid email",
      ),
    );
  }
}

class _CreateAccountPassword extends StatelessWidget {
  _CreateAccountPassword({
    Key? key,
    required this.passwordController,
  }) : super(key: key);
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.5,
      child: TextFormField(
        controller: passwordController,
        obscureText: true,
        decoration:
            const InputDecoration(hintText: 'Password', errorMaxLines: 3),
        validator: (value) {
          if (value == null || value.isEmpty || value.length < 6)
            return "Password must not be empty and not less than 6 characters!";
          else
            return null;
        },
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  _SubmitButton({
    Key? key,
    required this.onStateChanged,
    required this.email,
    required this.password,
  }) : super(key: key);

  final AuthStateCallback onStateChanged;
  final String email, password;
  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          onStateChanged(Status.authenticating);
          await _authService
              .createUserWithEmailAndPassword(
                email: email,
                password: password,
              )
              .then((value) => {createUserProfileIfNotExist(value, context)})
              .catchError((error) {
            onStateChanged(Status.authenticateError);
            Fluttertoast.showToast(msg: "Sign in fail");
          });
        } catch (e) {
          onStateChanged(Status.authenticateError);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
            ),
          );
        }
      },
      child: const Text('Create Account'),
    );
  }
}
