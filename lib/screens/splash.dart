import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

final kIsOnBoarded = "isOnBoarded";

class SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SharedPreferences.getInstance().then((prefs) {
      bool isOnBoarded = prefs.getBool(kIsOnBoarded) ?? false;
      if (isOnBoarded) {
        Navigator.of(context).pushReplacementNamed("/login");
      } else {
        Navigator.of(context).pushReplacementNamed("/onboarding");
      }
    });
  }

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
              text: "Harness the power of\n",
              children: [
                TextSpan(text: "your fan base and loyalty"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
