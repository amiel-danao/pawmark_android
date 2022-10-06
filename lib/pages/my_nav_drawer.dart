import 'package:flutter/material.dart';
import 'package:flutter_chat_demo/pages/pet_list_page.dart';
import 'package:flutter_chat_demo/pages/pet_tracker_page.dart';
import 'package:flutter_chat_demo/pages/settings_page.dart';

import 'home_page.dart';

class MyNavDrawer extends StatelessWidget {
  final Function() signOutFunction;

  const MyNavDrawer({Key? key, required this.signOutFunction})
      : super(key: key);

  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: Text(""),
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.scaleDown,
                    image: AssetImage('images/app_logo.png'))),
          ),
          ListTile(
            leading: Icon(Icons.catching_pokemon),
            title: Text('My Pets'),
            onTap: () => {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PetListPage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Chat'),
            onTap: () => {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Pet Tracker'),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PetTrackerPage()))
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => {
              Navigator.of(context).pop(),
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsPage()))
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
