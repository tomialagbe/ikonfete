import 'package:flutter/material.dart';
import 'package:ikonfetemobile/onboarding_screen.dart';

final appRoutes = <String, WidgetBuilder>{
  onBoardingRoute: (ctx) => OnBoardingScreen(),
  artistSignupRoute: (ctx) => null,
  fanSignupRoute: (ctx) => null,
};

final onBoardingRoute = "/onboarding";
final artistSignupRoute = "/artist_signup";
final fanSignupRoute = "/fan_signup";
