import 'package:flutter/material.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

final musicScreen = Screen(
  title: "Music",
  contentBuilder: (ctx) => MusicScreen(),
);

class MusicScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text("Music"),
      ),
    );
  }
}
