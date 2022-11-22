import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/constants/app_constants.dart';
import 'package:flutter_chat_demo/constants/color_constants.dart';
import 'package:flutter_chat_demo/providers/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/customer.dart';

import '../env.sample.dart';
import '../widgets/widgets.dart';
import 'pages.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  late Future<Customer>? futureCustomer;

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    switch (authProvider.status) {
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Sign in fail");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Sign in canceled");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Sign in success");
        break;
      default:
        break;
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: ColorConstants.primaryColor,
          title: Text(
            AppConstants.loginTitle,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            backgroundWidget(),

            Container(
              height: double.infinity,
              alignment: Alignment.topCenter,
              child: Container(
                  width: 200,
                  height: 150,
                  child: Image.asset('images/app_logo.png')),
            ),
            Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () async {
                      bool isSuccess = await authProvider.handleSignIn();
                      if (isSuccess) {
                        String uid = authProvider.firebaseAuth.currentUser!.uid;
                        String? email = authProvider.firebaseAuth.currentUser!.email;
                        createUserProfileIfNotExist(new Customer(id: uid, email: email));
                      }
                      else{
                        showSignInFailedDialog(context);
                      }
                    },
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed))
                            return Color(0xffdd4b39).withOpacity(0.8);
                          return Color(0xffdd4b39);
                        },
                      ),
                      splashFactory: NoSplash.splashFactory,
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.fromLTRB(30, 15, 30, 15),
                      ),
                    ),
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: new Text("Terms of Service and Privacy Policy."),
                )),
            // Loading
            Positioned(
              child: authProvider.status == Status.authenticating
                  ? LoadingView()
                  : SizedBox.shrink(),
            ),
          ],
          //)
        ));
  }

  Widget backgroundWidget() {
    return SizedBox.expand(
        child: FractionallySizedBox(
      widthFactor: 3,
      heightFactor: 0.65,
      alignment: FractionalOffset.bottomCenter,
      child: Image(
        image: AssetImage('images/background.png'),
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.fill,
      ),
    ));
  }

  showSignInFailedDialog(BuildContext context) {

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () { },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text("Failed to sign in"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<Customer>? createProfile(Customer customer) async{
    final response = await http.get(
      Uri.parse('${Env.URL_CUSTOMER}/${customer.id}')
    );

    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      return Customer.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 201 CREATED response,
      // then create a new customer profile
      final createResponse = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/albums'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: customer.toJson(),
      );

      if(createResponse.statusCode == 201){
        return Customer.fromJson(jsonDecode(response.body));
      }

      showSignInFailedDialog(context);
      throw Exception('Failed to create profile.');
    }
  }

  createUserProfileIfNotExist(Customer customer) {
    if (customer.email == null || customer.id.isEmpty){
      showSignInFailedDialog(context);
    }

    setState(() {
      futureCustomer = createProfile(customer);
    });

    futureCustomer?.then((value) => {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
        builder: (context) => HomePage(),
        ),
      )
    }).catchError((error) => {
      showSignInFailedDialog(context)
    });
  }
}
