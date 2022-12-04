import 'dart:convert';
import 'package:flutter_chat_demo/providers/auth_provider.dart';
import 'package:http/http.dart' as http;

import 'package:auth_service/auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../env.sample.dart';
import '../login/view/login_view.dart';
import '../pages/chat_list_page.dart';

// Future<Customer> createProfile(Customer customer) async {

// }

void gotoHomePage(value, context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ChatListPage(currentCustomer: value),
    ),
  );
}

Future<String> createUserProfileIfNotExist(
    Customer customer, BuildContext context) async {
  if (customer.email.isEmpty || customer.id.isEmpty) {
    Fluttertoast.showToast(msg: "Invalid login input!");
    throw Exception("Invalid login input!");
  }

  final response =
      await http.get(Uri.parse('${Env.URL_CUSTOMER}/${customer.id}'));

  if (response.statusCode == 200) {
    Customer fetchedCustomer = Customer.fromJson(jsonDecode(response.body));
    gotoHomePage(fetchedCustomer, context);
    return "OK";
  } else {
    final jsonData = jsonEncode(customer.toJson());

    final createResponse = await http.post(
      Uri.parse('${Env.URL_CUSTOMER}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );

    if (createResponse.statusCode == 201) {
      // func();
      gotoHomePage(customer, context);
      return "OK";
      // return Customer.fromJson(jsonDecode(response.body));
    }

    throw Exception("Sign in fail : ${createResponse.body.toString()}");
  }
}

Future<void> handleSignOut(
    BuildContext context, AuthProvider authProvider) async {
  authProvider.handleSignOut();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => LoginView()),
    (Route<dynamic> route) => false,
  );
}
