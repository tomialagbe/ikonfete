import 'dart:async';

import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/pending_verification.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/pending_verification.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/twitter_auth.dart';
import 'package:meta/meta.dart';

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
  StreamController<FacebookAuthResult> _facebookActionResultController =
      StreamController<FacebookAuthResult>.broadcast();

  StreamController _twitterActionController = StreamController();
  StreamController<TwitterAuthResult> _twitterActionResultController =
      StreamController<TwitterAuthResult>.broadcast();

  StreamController<VerifyParams> _verifyActionController =
      StreamController<VerifyParams>();
  StreamController<Pair<bool, String>> _verifyActionResultController =
      StreamController.broadcast();

  Sink get facebookAction => _facebookActionController.sink;

  Sink get twitterAction => _twitterActionController.sink;

  Sink<VerifyParams> get verifyAction => _verifyActionController.sink;

  Stream<FacebookAuthResult> get facebookActionResult =>
      _facebookActionResultController.stream;

  Stream<TwitterAuthResult> get twitterActionResult =>
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
    final fbAuth = FacebookAuth();
    final fbResult = await fbAuth.facebookAuth();
    _facebookActionResultController.add(fbResult);
  }

  void _handleTwitterAction() async {
    final twitterAuth = TwitterAuth(appConfig: appConfig);
    final tResult = await twitterAuth.twitterAuth();
    _twitterActionResultController.add(tResult);
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
