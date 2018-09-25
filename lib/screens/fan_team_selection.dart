import 'package:flutter/material.dart';

class FanTeamSelectionScreen extends StatefulWidget {
  @override
  FanTeamSelectionScreenState createState() => FanTeamSelectionScreenState();
}

class FanTeamSelectionScreenState extends State<FanTeamSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text("Fan team Selection"),
        ),
      ),
    );
  }
}
