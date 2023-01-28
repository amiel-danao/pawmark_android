import 'dart:convert';

import 'package:auth_service/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/constants/color_constants.dart';
import 'package:flutter_chat_demo/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../env.sample.dart';
import '../login/view/login_view.dart';
import 'pages.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key? key}) : super(key: key);

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      // just delay for showing this slash page clearer because it too fast

      checkSignedIn();
    });
  }

  void checkSignedIn() async {
    AuthProvider authProvider = context.read<AuthProvider>();
    bool isLoggedIn = await authProvider.isLoggedIn();
    if (isLoggedIn) {
      String? loggedInEmail = authProvider.firebaseAuth.currentUser!.email;
      String loggedInUid = authProvider.firebaseAuth.currentUser!.uid;

      if (loggedInEmail == null ||
          loggedInEmail.isEmpty ||
          loggedInUid.isEmpty) {
        gotoLoginPage();
        return;
      }

      final response =
          await http.get(Uri.parse('${Env.URL_CUSTOMER}/$loggedInUid'));

      if (response.statusCode == 200) {
        Customer customer = Customer.fromJson(jsonDecode(response.body));
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatListPage(currentCustomer: customer),
            ));
      } else {
        gotoLoginPage();
      }
    } else {
      gotoLoginPage();
    }
  }

  void gotoLoginPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "images/app_icon.png",
              width: 100,
              height: 100,
            ),
            SizedBox(height: 20),
            Container(
              width: 20,
              height: 20,
              child:
                  CircularProgressIndicator(color: ColorConstants.themeColor),
            ),
          ],
        ),
      ),
    );
  }
}
