import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:meta/meta.dart';

class TwitterAuthResult {
  bool canceled;
  bool success;
  String errorMessage;
  String twitterUID;
  String twitterUsername;

  TwitterAuthResult()
      : canceled = false,
        success = false;
}

class TwitterAuth {
  final AppConfig appConfig;

  TwitterAuth({@required this.appConfig});

  Future<TwitterAuthResult> twitterAuth() async {
    final twitterLogin = TwitterLogin(
      consumerKey: appConfig.twitterConfig.consumerKey,
      consumerSecret: appConfig.twitterConfig.consumerSecret,
    );
    await twitterLogin.logOut();
    final twitterLoginResult = await twitterLogin.authorize();
    if (twitterLoginResult.status == TwitterLoginStatus.loggedIn) {
      final tresult = TwitterAuthResult();
      tresult
        ..canceled = false
        ..success = true
        ..twitterUID = twitterLoginResult.session.userId
        ..twitterUsername = twitterLoginResult.session.username;
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
