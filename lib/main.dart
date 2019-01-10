import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/main_bloc.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/screens/artist_verification/artist_verification.dart';
import 'package:ikonfetemobile/screens/fan_team_selection/fan_team_selection.dart';
import 'package:ikonfetemobile/screens/home/artist_home.dart';
import 'package:ikonfetemobile/screens/home/fan_home/fan_home.dart';
import 'package:ikonfetemobile/screens/login/login.dart';
import 'package:ikonfetemobile/screens/onboarding.dart';
import 'package:ikonfetemobile/screens/pending_verification/pending_verification.dart';
import 'package:ikonfetemobile/screens/signup/user_signup_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IkonfeteApp extends StatefulWidget {
  final SharedPreferences preferences;

  IkonfeteApp({@required this.preferences});

  @override
  IkonfeteAppState createState() {
    return IkonfeteAppState();
  }
}

class IkonfeteAppState extends State<IkonfeteApp> {
  AppBloc _appBloc;

  @override
  void initState() {
    super.initState();
    defineRoutes(router);

    _appBloc = AppBloc(preferences: widget.preferences);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      bloc: _appBloc,
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
        supportedLocales: [
          Locale("en", "NG"),
        ],
        onGenerateTitle: (context) {
          return AppLocalizations.of(context).title;
        },
        onGenerateRoute: (settings) {
          final routeMatch = router.match(settings.name);
          final params = routeMatch.parameters;
          Handler handler = routeMatch.route.handler;
          return CupertinoPageRoute(
            builder: (ctx) {
              return handler.handlerFunc(ctx, params);
            },
            settings: settings,
          );
        },
        home: BlocBuilder<AppEvent, AppState>(
          bloc: _appBloc,
          builder: (context, state) {
            return getInitialScreen(context, state);
          },
        ),
      ),
    );
  }

  static Widget getInitialScreen(BuildContext context, AppState state) {
    if (!state.isOnBoarded) {
      return OnBoardingScreen();
    } else if (state.isLoggedIn) {
      if (!state.isProfileSetup) {
        return userSignupProfileScreen(context, state.uid);
      } else if (state.isArtist) {
        if (state.artistOrFan.first.isVerified) {
          return artistHomeScreen(context);
        } else if (state.artistOrFan.first.isPendingVerification) {
          return pendingVerificationScreen(context, state.uid);
        } else {
          return artistVerificationScreen(context, state.uid);
        }
      } else {
        // check if fan team is setup
        if (state.isFanTeamSetup) {
          return fanHomeScreen(context);
        } else {
          return teamSelectionScreen(context, state.uid);
        }
      }
    } else {
      return loginScreen(context);
    }

//    return signupScreen(context);
  }

/*@override
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
        supportedLocales: [
          Locale("en", "NG"),
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
                        uid: initState.currentUser.uid,
                      ),
                      child: UserSignupProfileScreen(
                        isArtist: initState.isArtist,
                      ),
                    );
                  } else if (initState.isArtist) {
                    if (initState.artist.isVerified) {
                      // Artist Home Screen
                      return ZoomScaffoldScreen(
                        isArtist: true,
                        screenId: 'home',
                        params: <String, String>{},
                      );
                    } else if (initState.artist.isPendingVerification) {
                      // pending verification screen
                      return BlocProvider<ArtistPendingVerificationBloc>(
                        bloc: ArtistPendingVerificationBloc(
                          uid: initState.currentUser.uid,
                          appConfig: AppConfig.of(ctx),
                        ),
                        child: ArtistPendingVerificationScreen(
                            uid: initState.currentUser.uid),
                      );
                    } else {
                      // to verification screen
                      return BlocProvider<ArtistVerificationBloc>(
                        bloc: ArtistVerificationBloc(
                            appConfig: AppConfig.of(ctx)),
                        child: ArtistVerificationScreen(
                            uid: initState.currentUser.uid),
                      );
                    }
                  } else {
                    // TODO: seek better alternatives
                    if (initState.isFanTeamSetup) {
                      // Fan Home Screen
                      return ZoomScaffoldScreen(
                        isArtist: false,
                        screenId: 'home',
                        params: <String, String>{},
                      );
                    } else {
                      return BlocProvider<FanTeamSelectionBloc>(
                        bloc:
                            FanTeamSelectionBloc(appConfig: AppConfig.of(ctx)),
                        child: FanTeamSelectionScreen(
                            uid: initState.currentUser.uid,
                            name: initState.currentUser.displayName),
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
  */
}
