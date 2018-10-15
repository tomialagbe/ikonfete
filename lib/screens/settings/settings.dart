import 'package:flutter/material.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

Screen settingsScreen() {
  return Screen(
    title: "SETTINGS",
    contentBuilder: (context) {
      return SettingsScreen();
    },
  );
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    print("SETTINGS SCREEN INITIALIZATION");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("SETTINGS"),
      ),
    );
  }
}
