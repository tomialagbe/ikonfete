import 'package:flutter/material.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/artist_home.dart';
import 'package:ikonfetemobile/bloc/artist_signup_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/login_bloc.dart';
import 'package:ikonfetemobile/screens/artist_signup.dart';
import 'package:ikonfetemobile/screens/login.dart';
import 'package:ikonfetemobile/screens/onboarding.dart';

Map<String, Widget> appRoutes(AppConfig appConfig) {
  return <String, Widget>{
    onBoarding: OnBoardingScreen(),
    artistSignup: BlocProvider<ArtistSignupBloc>(
      bloc: ArtistSignupBloc(appConfig),
      child: ArtistSignupScreen(),
    ),
    artistLogin: BlocProvider<LoginBloc>(
      bloc: LoginBloc(isArtist: true),
      child: LoginScreen(isArtist: true),
    ),
    fanSignup: null,
    artistHome: ArtistHome(),
    fanHome: null,
  };
}

final onBoarding = "/onboarding";
final artistSignup = "/artist_signup";
final artistLogin = "/artist_login";
final fanLogin = "/fan_login";
final fanSignup = "/fan_signup";
final artistHome = "/artist_home";
final fanHome = "/fan_home";
