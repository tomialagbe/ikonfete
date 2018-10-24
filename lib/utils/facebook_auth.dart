import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class FacebookAuthResult {
  bool canceled;
  bool success;
  String errorMessage;
  String facebookUID;

  FacebookAuthResult()
      : canceled = false,
        success = false;
}

class FacebookAuth {
  Future<FacebookAuthResult> facebookAuth() async {
    final facebookLogin = FacebookLogin();
    facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
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
