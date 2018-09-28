import 'package:flutter/material.dart';

class FanHomeScreen extends StatefulWidget {
  @override
  _FanHomeScreenState createState() => _FanHomeScreenState();
}

class _FanHomeScreenState extends State<FanHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
