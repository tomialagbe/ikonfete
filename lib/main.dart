import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/localization.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Ikonfete"),
          ),
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  onPressed: _facebookLogin,
                  child: Text("Facebook Login"),
                ),
                SizedBox(height: 20.0),
                RaisedButton(
                  onPressed: _twitterLogin,
                  child: Text("Twitter Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _facebookLogin() async {
    final appConfig = AppConfig.of(context);
    final facebookLogin = FacebookLogin();
    if (await facebookLogin.isLoggedIn) {
      print("USER ALREADY LOGGED IN");
    } else {
      final result = await facebookLogin
          .logInWithReadPermissions(['email', 'public_profile']);
      if (result.status == FacebookLoginStatus.loggedIn) {
        print("LOGIN SUCCESSFUL. TOKEN: ${result.accessToken.token}");
        final firebaseUser = await FirebaseAuth.instance
            .signInWithFacebook(accessToken: result.accessToken.token);
        print("LOGGED IN SUCCESSFULY: ${firebaseUser.uid}");
      } else if (result.status == FacebookLoginStatus.cancelledByUser) {
        print("LOGIN CANCELLED");
      } else {
        print("LOGIN FAILED: ${result.errorMessage}");
      }
    }
  }

  void _twitterLogin() async {
    final appConfig = AppConfig.of(context);
    final twitterLogin = TwitterLogin(
      consumerKey: appConfig.twitterConfig.consumerKey,
      consumerSecret: appConfig.twitterConfig.consumerSecret,
    );
    if (await twitterLogin.isSessionActive) {
      final token = ((await twitterLogin.currentSession).token);
      print("LOGGED IN WITH TWITTER. TOKEN: $token");
    } else {
      final twitterLoginResult = await twitterLogin.authorize();
      switch (twitterLoginResult.status) {
        case TwitterLoginStatus.loggedIn:
          final firebaseUser = await FirebaseAuth.instance.signInWithTwitter(
              authToken: twitterLoginResult.session.token,
              authTokenSecret: twitterLoginResult.session.secret);
          print("LOGGED IN SUCCESSFULY: ${firebaseUser.uid}");
          break;
        case TwitterLoginStatus.cancelledByUser:
        case TwitterLoginStatus.error:
        default:
          print("TWITTER LOGIN FAILED");
          break;
      }
    }
  }
}
