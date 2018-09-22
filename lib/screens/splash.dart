import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:ikonfetemobile/localization.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: screenSize.width,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              "assets/images/splash_background.png",
              fit: BoxFit.fill,
              width: screenSize.width,
              height: screenSize.height,
            ),
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
                child: _buildLogoAndText(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoAndText() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Image.asset(
            "assets/images/Ikonfete_logo_white.png",
            width: 250.0,
            height: 100.0,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 60.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.white),
              text: AppLocalizations.of(context).splashScreenText,
            ),
          ),
        ),
      ],
    );
  }
}
