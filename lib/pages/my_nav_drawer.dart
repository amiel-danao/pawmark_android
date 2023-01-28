import 'package:auth_service/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/pages/pet_list_page.dart';
import 'package:flutter_chat_demo/pages/pet_tracker_page.dart';
import 'package:flutter_chat_demo/pages/profile_page.dart';

import '../widgets/notif_widget.dart';
import 'chat_list_page.dart';
import 'notification_page.dart';

class MyNavDrawer extends StatelessWidget {
  final Function() signOutFunction;
  final Customer currentCustomer;
  final int counter;

  const MyNavDrawer(
      {Key? key,
      required this.signOutFunction,
      required this.currentCustomer,
      required this.counter})
      : super(key: key);

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Image(
              image: AssetImage('images/app_logo.png'),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            leading: Icon(Icons.catching_pokemon),
            title: Text('My Pets'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PetListPage(currentCustomer: currentCustomer)))
            },
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(currentCustomer: currentCustomer)))
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Chat'),
            onTap: () => {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatListPage(currentCustomer: currentCustomer)))
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Pet Tracker'),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PetTrackerPage(currentCustomer: currentCustomer)))
            },
          ),
          ListTile(
            leading: NotifWidget(
              counter: counter.toString(),
            ),
            title: Text('Notifications'),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NotificationPage(currentCustomer: currentCustomer)))
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () => {signOutFunction()},
          ),
        ],
      ),
    );
  }
}
