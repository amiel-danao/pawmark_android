import 'package:flutter_chat_demo/signup/view/signup_view.dart';
import 'package:auth_service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:email_validator/email_validator.dart';

import '../../api/customer_controller.dart';
import '../../constants/app_constants.dart';
import '../../constants/color_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/background_widget.dart';
import '../../widgets/loading_view.dart';

class LoginView extends StatefulWidget {
  LoginView({Key? key}) : super(key: key);

  @override
  LoginViewState createState() {
    return LoginViewState();
  }
}

class LoginViewState extends State<LoginView> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  Status _status = Status.uninitialized;

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: "amielrenaissance4@gmail.com");
    _passwordController = TextEditingController(text: "sixtynine6^");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Login'),
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
                      _LoginEmail(emailController: _emailController),
                      const SizedBox(height: 30.0),
                      _LoginPassword(passwordController: _passwordController),
                      const SizedBox(height: 30.0),
                      _SubmitButton(
                        onStateChanged: (status) => setState(() {
                          _status = status;
                        }),
                        formKey: _formKey,
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                      const SizedBox(height: 30.0),
                      _CreateAccountButton(),
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

class _LoginEmail extends StatelessWidget {
  _LoginEmail({
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

class _LoginPassword extends StatelessWidget {
  _LoginPassword({
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

class _SubmitButton extends StatefulWidget {
  _SubmitButton({
    Key? key,
    required this.onStateChanged,
    required this.formKey,
    required this.email,
    required this.password,
  }) : super(key: key);

  final AuthStateCallback onStateChanged;
  final formKey;
  final String email, password;
  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  @override
  State<StatefulWidget> createState() => SubmitState();
}

class SubmitState extends State<_SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (widget.formKey.currentState!.validate()) {
          try {
            widget.onStateChanged(Status.authenticating);
            await widget._authService
                .signInWithEmailAndPassword(
                  email: widget.email,
                  password: widget.password,
                )
                .then((value) => {createUserProfileIfNotExist(value, context)})
                .catchError((error) {
              widget.onStateChanged(Status.authenticateError);
              Fluttertoast.showToast(msg: "Sign in fail : ${error.toString()}");
            });
          } catch (e) {
            widget.onStateChanged(Status.authenticateError);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Invalid login input!"),
            ),
          );
        }
      },
      child: const Text('Login'),
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SignUpView(),
          ),
        );
      },
      child: const Text('Create Account'),
    );
  }
}
