import 'package:flutter/material.dart';

class UiHelpers {
  static AppBar appBar(
      {@required String title,
      Color backgroundColor,
      Widget leading,
      Widget trailing}) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0.0,
      leading: leading,
      actions: trailing != null
          ? <Widget>[
              trailing,
            ]
          : <Widget>[],
      centerTitle: true,
      title: new Text(
        title,
        style: new TextStyle(
          fontFamily: 'SanFranciscoDisplay',
          fontSize: 25.0,
          color: Colors.black54,
        ),
      ),
    );
  }
}
