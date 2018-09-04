import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:ikonfetemobile/app_config.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Ikonfete"),
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                onPressed: () => _facebookLogin(context),
                child: Text("Facebook Login"),
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                onPressed: () => _twitterLogin(context),
                child: Text("Twitter Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _facebookLogin(BuildContext context) async {
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

  void _twitterLogin(BuildContext context) async {
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
