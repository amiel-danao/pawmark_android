import 'dart:io';

import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

Future<void> openDialog(context) async {
  switch (await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              color: ColorConstants.themeColor,
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.exit_to_app,
                      size: 30,
                      color: Colors.white,
                    ),
                    margin: EdgeInsets.only(bottom: 10),
                  ),
                  Text(
                    'Exit app',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Are you sure to exit app?',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 0);
              },
              child: Row(
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.cancel,
                      color: ColorConstants.primaryColor,
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Text(
                    'Cancel',
                    style: TextStyle(
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 1);
              },
              child: Row(
                children: <Widget>[
                  Container(
                    child: Icon(
                      Icons.check_circle,
                      color: ColorConstants.primaryColor,
                    ),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Text(
                    'Yes',
                    style: TextStyle(
                        color: ColorConstants.primaryColor,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ],
        );
      })) {
    case 0:
      break;
    case 1:
      exit(0);
  }
}
