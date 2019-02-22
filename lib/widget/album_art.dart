import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';

class AlbumArt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: primaryColor.withOpacity(0.1),
                blurRadius: 10.0,
                offset: Offset(0.0, 5.0))
          ],
//          image: DecorationImage(
//            fit: BoxFit.fill,
//            image: AssetImage("assets/images/onboard_background2.png"),
//          ),
        ),
//        child: Container(
//          decoration: BoxDecoration(
//            border: Border.all(color: Colors.white, width: 2.0),
//            color: Colors.white,
//            shape: BoxShape.circle,
//          ),
//          height: 10.0,
//          width: 10.0,
//        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
//            Image.asset(
//              "assets/images/onboard_background2.png",
//              fit: BoxFit.cover,
//            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2.0),
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              height: 10.0,
              width: 10.0,
            ),
          ],
        ),
      ),
    );
  }
}
