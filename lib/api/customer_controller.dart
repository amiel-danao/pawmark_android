import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_chat_demo/providers/auth_provider.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:http/http.dart' as http;

import 'package:auth_service/auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants/app_constants.dart';
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

Future<void> createDeviceToken(String token, String uid) async {
  if (uid.isEmpty || token.isEmpty) {
    return;
  }
  try {
    final jsonData = json.encode({"token": token, "customer": uid});

    final createResponse = await http.post(
      Uri.parse('${Env.URL_DEVICE_TOKEN}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );

    print('createDeviceToken response code : ${createResponse.statusCode}');
    print(createResponse.body);
  } on Exception catch (error) {
    print(error);
  }
}

Future<String> createUserProfileIfNotExist(
    Customer customer, BuildContext context,
    {bool register = false}) async {
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
    // String? displayName = user.currentUser!.displayName;
    var json = customer.toJson();

    // if (customer.firstName!.isEmpty && displayName != null) {
    //   List<String> splittedName = displayName.split(',');
    //   json['firstname'] = splittedName[0];
    //   json['middlename'] = splittedName[1];
    //   json['lastname'] = splittedName[2];
    // }
    final jsonData = jsonEncode(json);

    final createResponse = await http.post(
      Uri.parse('${Env.URL_CUSTOMER}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );

    if (createResponse.statusCode == 201) {
      // func();
      if (!register) {
        gotoHomePage(customer, context);
      }
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

void listenToNotifications(
    String? uid, NotitificationReceivedAttachedCallback callback) {
  if (uid == null) {
    return;
  }
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      if (message.data['user_id'] == uid) {
        print('Message also contained a notification: ${message.notification}');
        callback.call();
        FlutterRingtonePlayer.playNotification();
      }
    }
  });
}
