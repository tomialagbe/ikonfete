import 'package:flutter/material.dart';

// TODO:
class Alerts {
  static Alert error(String text) {
    return Alert(
      text: text,
      backgroundColor: const Color(0xFFFF6A70),
    );
  }
}

class Alert extends StatelessWidget {
  final String text;
  final Color backgroundColor;

  Alert({
    this.text,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: backgroundColor.withRed(
                backgroundColor.red + (0.2 * backgroundColor.red).toInt())),
      ),
    );
  }
}
