import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/artist_signup_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/screens/artist_login.dart';
import 'package:ikonfetemobile/screens/artist_signup.dart';
import 'package:ikonfetemobile/screens/onboarding.dart';

final appRoutes = <String, Widget>{
  onBoarding: OnBoardingScreen(),
  artistSignup: BlocProvider<ArtistSignupBloc>(
    bloc: ArtistSignupBloc(),
    child: ArtistSignupScreen(),
  ),
  artistLogin: ArtistLoginScreen(),
  fanSignup: null,
};

final onBoarding = "/onboarding";
final artistSignup = "/artist_signup";
final artistLogin = "/artist_login";
final fanSignup = "/fan_signup";
