import 'package:flutter/material.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

final messagingScreen = Screen(
  title: "Messaging",
  contentBuilder: (ctx) => MessagingScreen(),
);

class MessagingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text("Messaging"),
      ),
    );
  }
}
