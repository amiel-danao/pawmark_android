import 'package:flutter/material.dart';

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
