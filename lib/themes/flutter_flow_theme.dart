import 'package:flutter/material.dart';

class FlutterFlowTheme extends Theme {
  FlutterFlowTheme({required ThemeData data, required Widget child})
      : super(data: data, child: child);

  static of(BuildContext context) {
    return Theme.of(context);
  }
}
