import 'dart:async';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/pending_verification.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/pending_verification.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';

class FacebookActionResult {
  bool canceled;
  bool success;
  String errorMessage;
  String facebookUID;

  FacebookActionResult()
      : canceled = false,
        success = false;
}

class TwitterActionResult {
  bool canceled;
  bool success;
  String errorMessage;
  String twitterUID;
  String twitterUsername;

  TwitterActionResult()
      : canceled = false,
        success = false;
}

class VerifyParams {
  String fbId;
  String twitterId;
  String twitterUsername;
  String bio;
  String uid;
}

class ArtistVerificationBloc extends BlocBase {
  final AppConfig appConfig;

  StreamController _facebookActionController = StreamController();
  StreamController<FacebookActionResult> _facebookActionResultController =
      StreamController<FacebookActionResult>.broadcast();

  StreamController _twitterActionController = StreamController();
  StreamController<TwitterActionResult> _twitterActionResultController =
      StreamController<TwitterActionResult>.broadcast();

  StreamController<VerifyParams> _verifyActionController =
      StreamController<VerifyParams>();
  StreamController<Pair<bool, String>> _verifyActionResultController =
      StreamController.broadcast<Pair<bool, String>>();

  Sink get facebookAction => _facebookActionController.sink;

  Sink get twitterAction => _twitterActionController.sink;

  Sink<VerifyParams> get verifyAction => _verifyActionController.sink;

  Stream<FacebookActionResult> get facebookActionResult =>
      _facebookActionResultController.stream;

  Stream<TwitterActionResult> get twitterActionResult =>
      _twitterActionResultController.stream;

  Stream<Pair<bool, String>> get verifyActionResult =>
      _verifyActionResultController.stream;

  ArtistVerificationBloc({@required this.appConfig}) {
    _facebookActionController.stream.listen((_) => _handleFacebookAction());
    _twitterActionController.stream.listen((_) => _handleTwitterAction());
    _verifyActionController.stream.listen(_handleVerifyAction);
  }

  @override
  void dispose() {
    _facebookActionController.close();
    _facebookActionResultController.close();
    _twitterActionController.close();
    _twitterActionResultController.close();
    _verifyActionController.close();
    _verifyActionResultController.close();
  }

  void _handleFacebookAction() async {
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
      final fbResult = FacebookActionResult();
      fbResult
        ..success = true
        ..canceled = false
        ..facebookUID = result.accessToken.userId;
      _facebookActionResultController.add(fbResult);
    } else if (result.status == FacebookLoginStatus.cancelledByUser) {
      // login cancelled
      final fbResult = FacebookActionResult();
      fbResult
        ..canceled = true
        ..success = false;
      _facebookActionResultController.add(fbResult);
    } else {
      final fbResult = FacebookActionResult();
      fbResult
        ..canceled = false
        ..success = false
        ..errorMessage = result.errorMessage;
      _facebookActionResultController.add(fbResult);
    }
  }

  void _handleTwitterAction() async {
    final twitterLogin = TwitterLogin(
      consumerKey: appConfig.twitterConfig.consumerKey,
      consumerSecret: appConfig.twitterConfig.consumerSecret,
    );
    await twitterLogin.logOut();
    final twitterLoginResult = await twitterLogin.authorize();
    if (twitterLoginResult.status == TwitterLoginStatus.loggedIn) {
      final tresult = TwitterActionResult();
      tresult
        ..canceled = false
        ..success = true
        ..twitterUID = twitterLoginResult.session.userId
        ..twitterUsername = twitterLoginResult.session.username;
      _twitterActionResultController.add(tresult);
    } else if (twitterLoginResult.status ==
        TwitterLoginStatus.cancelledByUser) {
      final tresult = TwitterActionResult();
      tresult
        ..success = false
        ..canceled = true;
      _twitterActionResultController.add(tresult);
    } else {
      final tresult = TwitterActionResult();
      tresult
        ..success = false
        ..canceled = false
        ..errorMessage = twitterLoginResult.errorMessage;
      _twitterActionResultController.add(tresult);
    }
  }

  void _handleVerifyAction(VerifyParams params) async {
    try {
      final pendingVerification = PendingVerification()
        ..uid = params.uid
        ..bio = params.bio
        ..facebookId = params.fbId
        ..twitterId = params.twitterId;
      final pendingVerificationApi =
          PendingVerificationApi(appConfig.serverBaseUrl);

      final success = await pendingVerificationApi
          .createPendingVerification(pendingVerification);

      _verifyActionResultController.add(Pair.from(success, null));
    } on ApiException catch (e) {
      _verifyActionResultController.add(Pair.from(false, e.message));
    }
  }
}
