import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/login_bloc.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/screens/login.dart';
import 'package:ikonfetemobile/screens/onboarding.dart';
import 'package:ikonfetemobile/screens/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new IkonfeteApp());

class IkonfeteApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  IkonfeteAppState createState() {
    return IkonfeteAppState();
  }
}

class IkonfeteAppState extends State<IkonfeteApp> {
  @override
  void initState() {
    super.initState();
    defineRoutes(router, null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApplicationBloc>(
      bloc: ApplicationBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "SanFranciscoDisplay",
        ),
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
//      supportedLocales: [Locale("en", ""), Locale("es", ""), Locale("pt", "")],
        supportedLocales: [
          Locale("en", ""),
        ],
        onGenerateTitle: (context) {
          return AppLocalizations.of(context).title;
        },
        home: FutureBuilder<OnBoardState>(
          initialData: null,
          future: _getOnBoardState(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.isOnBoarded) {
                // check if the user has signed up
                return BlocProvider<LoginBloc>(
                  child: LoginScreen(isArtist: snapshot.data.isArtist),
                  bloc: LoginBloc(isArtist: snapshot.data.isArtist),
                );
              } else {
                // user not onboarded, show onboarding screen
                return OnBoardingScreen();
              }
            } else {
              return SplashScreen();
            }
          },
        ),
      ),
    );
  }

  Future<OnBoardState> _getOnBoardState() async {
    final prefs = await SharedPreferences.getInstance();
    final isOnBoarded = prefs.getBool(PreferenceKeys.isOnBoarded) ?? false;
    final isArtist = prefs.getBool(PreferenceKeys.isArtist) ?? false;
    final state = OnBoardState()
      ..isArtist = isArtist
      ..isOnBoarded = isOnBoarded;
    return state;
  }
}

class OnBoardState {
  bool isOnBoarded = false;
  bool isArtist = false;
}
