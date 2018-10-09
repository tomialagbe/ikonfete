import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/login_bloc.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/screens/artist_home.dart';
import 'package:ikonfetemobile/screens/fan_home.dart';
import 'package:ikonfetemobile/screens/fan_team_selection/fan_team_selection.dart';
import 'package:ikonfetemobile/screens/fan_team_selection/fan_team_selection_bloc.dart';
import 'package:ikonfetemobile/screens/login.dart';
import 'package:ikonfetemobile/screens/onboarding.dart';
import 'package:ikonfetemobile/screens/splash.dart';

class IkonfeteApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  IkonfeteAppState createState() {
    return IkonfeteAppState();
  }
}

class IkonfeteAppState extends State<IkonfeteApp> {
  ApplicationBloc _bloc;

  @override
  void initState() {
    super.initState();
    defineRoutes(router, null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = ApplicationBloc();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ApplicationBloc>(
      bloc: _bloc,
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
        home: FutureBuilder<AppInitState>(
          initialData: null,
          future: _bloc.getAppInitState(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              final initState = snapshot.data;
              if (initState.isOnBoarded) {
                // check if the user has signed up
                if (initState.isLoggedIn) {
                  if (initState.isArtist) {
                    return ArtistHomeScreen();
                  } else {
                    // TODO: seek better alternatives
                    if (initState.isFanTeamSetup) {
                      return FanHomeScreen();
                    } else {
                      return BlocProvider<FanTeamSelectionBloc>(
                        bloc: FanTeamSelectionBloc(),
                        child: FanTeamSelectionScreen(
                            uid: initState.uid, name: initState.name),
                      );
                    }
                  }
                } else {
                  return BlocProvider<LoginBloc>(
                    child: LoginScreen(isArtist: initState.isArtist),
                    bloc: LoginBloc(
                      isArtist: initState.isArtist,
                      appConfig: AppConfig.of(context),
                    ),
                  );
                }
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
}
