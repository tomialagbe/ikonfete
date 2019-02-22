import 'dart:math';

import 'package:flutter/material.dart';

class RandomGradientImage extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  RandomGradientImage({
    this.child,
    this.width: 64.0,
    this.height: 64.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(32.0),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.fromARGB(
              200,
              Random().nextInt(255),
              Random().nextInt(255),
              Random().nextInt(255),
            ).withOpacity(.8),
            Colors.grey.withOpacity(.8),
          ],
        ),
      ),
      child: child ?? Container(),
    );
  }
}
