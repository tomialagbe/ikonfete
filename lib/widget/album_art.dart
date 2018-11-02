import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';

class AlbumArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Container(
        // constraints: BoxConstraints( minHeight: 30.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 15.0,
                offset: Offset(0.0, 5.0))
          ],
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/images/onboard_background1.png"),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2.0),
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          height: 14.0,
          width: 14.0,
        ),
      ),
    );
  }
}
