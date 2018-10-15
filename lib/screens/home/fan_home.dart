import 'package:flutter/material.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

final fanHomeScreen = new Screen(
  title: "HOME",
  contentBuilder: (BuildContext context) {
    return FanHomeScreen();
  },
);

class FanHomeScreen extends StatefulWidget {
  @override
  _FanHomeScreenState createState() => _FanHomeScreenState();
}

class _FanHomeScreenState extends State<FanHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text("FAN HOME"),
      ),
    );
  }
}
