import 'package:auth_service/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/login/view/login_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

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
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  Status _status = Status.uninitialized;

  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthProvider>();
  }

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
                              value.length == 0 ||
                              value.contains(','))
                            return "Please input a valid First name";
                          else
                            return null;
                        },
                      ),
                      ProfileAccountName(
                        controller: _middleNameController,
                        placeHolder: 'Middle name',
                        textValidator: (value) {
                          if (value!.contains(',')) {
                            return "Please input a valid Middle name";
                          } else {
                            return null;
                          }
                        },
                      ),
                      ProfileAccountName(
                        controller: _lastNameController,
                        placeHolder: 'Last name',
                        textValidator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length == 0 ||
                              value.contains(','))
                            return "Please input a valid Last name";
                          else
                            return null;
                        },
                      ),
                      ProfileAccountEmail(emailController: _emailController),
                      ProfileAccountPassword(
                          passwordController: _passwordController,
                          otherPasswordController: _confirmPasswordController,
                          label: "Password"),
                      ProfileAccountPassword(
                          passwordController: _confirmPasswordController,
                          otherPasswordController: _passwordController,
                          label: "Confirm Password"),
                      const SizedBox(height: 30.0),
                      _SubmitButton(
                          authProvider: authProvider,
                          formKey: _formKey,
                          firstName: _firstNameController,
                          middleName: _middleNameController,
                          lastName: _lastNameController,
                          email: _emailController,
                          password: _passwordController,
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
      required this.formKey,
      required this.authProvider})
      : super(key: key);

  final formKey;
  final AuthStateCallback onStateChanged;
  final TextEditingController firstName, middleName, lastName, email, password;
  final AuthService _authService = FirebaseAuthService(
    authService: FirebaseAuth.instance,
  );

  final AuthProvider authProvider;

  void _submit(BuildContext context) async {
    final isValid = formKey.currentState.validate();
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invalid input!"),
        ),
      );
      return;
    }

    formKey.currentState.save();

    try {
      onStateChanged(Status.authenticating);
      await _authService
          .createUserWithEmailAndPassword(
        firstName: firstName.text,
        middleName: middleName.text,
        lastName: lastName.text,
        email: email.text,
        password: password.text,
      )
          .then((value) async {
        authProvider.firebaseAuth.currentUser!.sendEmailVerification();

        await createUserProfileIfNotExist(value, context, register: true)
            .then((value) {})
            .catchError((error) {
          onStateChanged(Status.authenticateError);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Registration Successfult!\nAn email verification was sent!'),
        ));

        Navigator.of(context).pop();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginView()));
      }).catchError((error) {
        onStateChanged(Status.authenticateError);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Registration fail:${error.toString()}"),
          ),
        );
      });
    } catch (e) {
      onStateChanged(Status.authenticateError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _submit(context),
      child: const Text('Create Account'),
    );
  }
}
