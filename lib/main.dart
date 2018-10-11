import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/artist_verification_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/login_bloc.dart';
import 'package:ikonfetemobile/bloc/pending_verification_bloc.dart';
import 'package:ikonfetemobile/bloc/user_signup_profile_bloc.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/screens/artist_home.dart';
import 'package:ikonfetemobile/screens/artist_verification.dart';
import 'package:ikonfetemobile/screens/fan_home.dart';
import 'package:ikonfetemobile/screens/fan_team_selection/fan_team_selection.dart';
import 'package:ikonfetemobile/screens/fan_team_selection/fan_team_selection_bloc.dart';
import 'package:ikonfetemobile/screens/init_error.dart';
import 'package:ikonfetemobile/screens/login.dart';
import 'package:ikonfetemobile/screens/onboarding.dart';
import 'package:ikonfetemobile/screens/pending_verification.dart';
import 'package:ikonfetemobile/screens/splash.dart';
import 'package:ikonfetemobile/screens/user_signup_profile.dart';

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
      _bloc = ApplicationBloc(appConfig: AppConfig.of(context));
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
            if (snapshot.hasError) {
              // show init error screen
              return InitErrorScreen(
                message: snapshot.error.toString(),
                retryHandler: () {
                  setState(() {}); // reload the app
                },
              );
            } else if (snapshot.hasData) {
              final initState = snapshot.data;
              if (initState.isOnBoarded) {
                // check if the user has signed in
                if (initState.isLoggedIn) {
                  if (!initState.isProfileSetup) {
                    return BlocProvider<UserSignupProfileBloc>(
                      bloc: UserSignupProfileBloc(
                        appConfig: AppConfig.of(ctx),
                        isArtist: initState.isArtist,
                        uid: initState.uid,
                      ),
                      child: UserSignupProfileScreen(
                        isArtist: initState.isArtist,
                      ),
                    );
                  } else if (initState.isArtist) {
                    if (initState.isArtistVerified) {
                      return ArtistHomeScreen();
                    } else if (initState.isArtistPendingVerification) {
                      // pending verification screen
                      return BlocProvider<ArtistPendingVerificationBloc>(
                        bloc: ArtistPendingVerificationBloc(
                          uid: initState.uid,
                          appConfig: AppConfig.of(ctx),
                        ),
                        child:
                            ArtistPendingVerificationScreen(uid: initState.uid),
                      );
                    } else {
                      // to verification screen
                      return BlocProvider<ArtistVerificationBloc>(
                        bloc: ArtistVerificationBloc(
                            appConfig: AppConfig.of(ctx)),
                        child: ArtistVerificationScreen(uid: initState.uid),
                      );
                    }
                  } else {
                    // TODO: seek better alternatives
                    if (initState.isFanTeamSetup) {
                      return FanHomeScreen();
                    } else {
                      return BlocProvider<FanTeamSelectionBloc>(
                        bloc:
                            FanTeamSelectionBloc(appConfig: AppConfig.of(ctx)),
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
