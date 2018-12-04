import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class FacebookAuthResult {
  bool canceled;
  bool success;
  String errorMessage;
  String facebookUID;
  String accessToken;

  FacebookAuthResult()
      : canceled = false,
        success = false;
}

class FacebookAuth {
  static final FacebookAuth _instance = FacebookAuth._internal();

  FacebookLogin facebookLogin;

  factory FacebookAuth() {
    return _instance;
  }

  FacebookAuth._internal() {
    facebookLogin = FacebookLogin();
    facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
  }

  Future<bool> isLoggedIn() {
    return facebookLogin.isLoggedIn;
  }

  Future<String> facebookAccessToken() async {
    if (await isLoggedIn()) {
      final at = await facebookLogin.currentAccessToken;
      return at.token;
    }
    return null;
  }

  Future<FacebookAuthResult> facebookAuth() async {
    await facebookLogin.logOut();
    final result = await facebookLogin.logInWithReadPermissions(
      [
        'email',
        'public_profile',
        'user_posts',
        'user_events',
      ],
    );

    if (result.status == FacebookLoginStatus.loggedIn) {
      // make a call to the facebook api to get the user's details
      final fbResult = FacebookAuthResult();
      fbResult
        ..success = true
        ..canceled = false
        ..accessToken = result.accessToken.token
        ..facebookUID = result.accessToken.userId;
      return fbResult;
    } else if (result.status == FacebookLoginStatus.cancelledByUser) {
      // login cancelled
      final fbResult = FacebookAuthResult();
      fbResult
        ..canceled = true
        ..success = false;
      return fbResult;
    } else {
      final fbResult = FacebookAuthResult();
      fbResult
        ..canceled = false
        ..success = false
        ..errorMessage = result.errorMessage;
      return fbResult;
    }
  }
}
