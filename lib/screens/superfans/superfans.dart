import 'package:flutter/material.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

final superfansScreen = Screen(
  title: "SUPERFANS",
  contentBuilder: (ctx) => SuperFansScreen(),
);

class SuperFansScreen extends StatefulWidget {
  @override
  _SuperFansScreenState createState() => _SuperFansScreenState();
}

class _SuperFansScreenState extends State<SuperFansScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text("SUPERFANS"),
      ),
    );
  }
}
