import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:auth_service/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../env.sample.dart';
import '../pages/home_page.dart';

// Future<Customer> createProfile(Customer customer) async {

// }

void gotoHomePage(value, context) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(currentCustomer: value),
    ),
  );
}

void createUserProfileIfNotExist(
    Customer customer, BuildContext context) async {
  if (customer.email.isEmpty || customer.id.isEmpty) {
    Fluttertoast.showToast(msg: "Invalid login input!");
  }

  // createProfile(customer)
  //     .then((value) => func)
  //     .catchError((error) => {Fluttertoast.showToast(msg: error)});

  final response =
      await http.get(Uri.parse('${Env.URL_CUSTOMER}/${customer.id}'));

  if (response.statusCode == 200) {
    // func();
    gotoHomePage(customer, context);
    // return Customer.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then create a new customer profile
    final jsonData = jsonEncode(customer.toJson());

    try {
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
        // return Customer.fromJson(jsonDecode(response.body));
      }

      print("Sign in fail : ${createResponse.body.toString()}");
    } catch (exception) {
      print("Sign in fail : ${exception.toString()}");
      Fluttertoast.showToast(msg: "Sign in fail : ${exception.toString()}");
    }

    throw Exception('Failed to create profile.');
  }
}
