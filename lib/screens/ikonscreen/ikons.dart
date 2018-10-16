import 'package:flutter/material.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

final Screen ikonScreen = Screen(
  title: "IKON",
  contentBuilder: (ctx) {
    return IkonScreen();
  },
);

class IkonScreen extends StatefulWidget {
  @override
  _IkonScreenState createState() => _IkonScreenState();
}

class _IkonScreenState extends State<IkonScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text("IKON SCREEN"),
      ),
    );
  }
}
