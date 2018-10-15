import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';

Future<bool> canLogout(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (c) {
      return AlertDialog(
        title: Text("Logout?"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                "Are you sure you want to logout of Ikonfete?",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(
              "YES",
              style: TextStyle(color: primaryColor),
            ),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(
              "NO",
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      );
    },
    barrierDismissible: false,
  );
}
