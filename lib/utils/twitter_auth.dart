import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:meta/meta.dart';

class TwitterAuthResult {
  bool canceled;
  bool success;
  String errorMessage;
  String twitterUID;
  String twitterUsername;
  String token;
  String tokenSecret;

  TwitterAuthResult()
      : canceled = false,
        success = false;
}

class TwitterAuth {
  final AppConfig appConfig;
  TwitterLogin twitterLogin;

  TwitterAuth({@required this.appConfig}) {
    twitterLogin = TwitterLogin(
      consumerKey: appConfig.twitterConfig.consumerKey,
      consumerSecret: appConfig.twitterConfig.consumerSecret,
    );
  }

  Future<bool> isLoggedIn() {
    return twitterLogin.isSessionActive;
  }

  Future<TwitterAuthResult> twitterAuth() async {
    await twitterLogin.logOut();
    final twitterLoginResult = await twitterLogin.authorize();
    if (twitterLoginResult.status == TwitterLoginStatus.loggedIn) {
      final tresult = TwitterAuthResult();
      tresult
        ..canceled = false
        ..success = true
        ..twitterUID = twitterLoginResult.session.userId
        ..twitterUsername = twitterLoginResult.session.username
        ..tokenSecret = twitterLoginResult.session.secret
        ..token = twitterLoginResult.session.token;
      return tresult;
    } else if (twitterLoginResult.status ==
        TwitterLoginStatus.cancelledByUser) {
      final tresult = TwitterAuthResult();
      tresult
        ..success = false
        ..canceled = true;
      return tresult;
    } else {
      final tresult = TwitterAuthResult();
      tresult
        ..success = false
        ..canceled = false
        ..errorMessage = twitterLoginResult.errorMessage;
      return tresult;
    }
  }
}
