import 'package:auth_service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../api/customer_controller.dart';
import '../../constants/app_constants.dart';
import '../../constants/color_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/background_widget.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/profile_widgets.dart';

class SignUpView extends StatefulWidget {
  SignUpView({Key? key}) : super(key: key);

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUpView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Status _status = Status.uninitialized;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            child: SingleChildScrollView(
          child: DecoratedBox(
            decoration:
                const BoxDecoration(color: Color.fromARGB(211, 252, 252, 252)),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ProfileAccountName(
                        controller: _firstNameController,
                        placeHolder: 'First name',
                        textValidator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length == 0)
                            return "Please input First name";
                          else
                            return null;
                        },
                      ),
                      ProfileAccountName(
                        controller: _middleNameController,
                        placeHolder: 'Middle name',
                      ),
                      ProfileAccountName(
                        controller: _lastNameController,
                        placeHolder: 'Last name',
                        textValidator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length == 0)
                            return "Please input Last name";
                          else
                            return null;
                        },
                      ),
                      ProfileAccountEmail(emailController: _emailController),
                      const SizedBox(height: 30.0),
                      ProfileAccountPassword(
                          passwordController: _passwordController),
                      const SizedBox(height: 30.0),
                      _SubmitButton(
                          formKey: _formKey,
                          firstName: _firstNameController.text,
                          middleName: _middleNameController.text,
                          lastName: _lastNameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                          onStateChanged: (status) => setState(() {
                                _status = status;
                              })),
                    ],
                  ),
                )),
          ),
        )),
        Positioned(
          child: _status == Status.authenticating
              ? LoadingView()
              : SizedBox.shrink(),
        )
      ]),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  _SubmitButton(
      {Key? key,
      required this.firstName,
      required this.middleName,
      required this.lastName,
      required this.email,
      required this.password,
      required this.onStateChanged,
      required this.formKey})
      : super(key: key);

  final formKey;
  final AuthStateCallback onStateChanged;
  final String firstName, middleName, lastName, email, password;
  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          try {
            onStateChanged(Status.authenticating);
            await _authService
                .createUserWithEmailAndPassword(
              firstName: firstName,
              middleName: middleName,
              lastName: lastName,
              email: email,
              password: password,
            )
                .then((value) {
              createUserProfileIfNotExist(value, context);
            }).catchError((error) {
              onStateChanged(Status.authenticateError);
              Fluttertoast.showToast(msg: "Registration fail");
            });
          } catch (e) {
            onStateChanged(Status.authenticateError);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Invalid input!"),
            ),
          );
        }
      },
      child: const Text('Create Account'),
    );
  }
}