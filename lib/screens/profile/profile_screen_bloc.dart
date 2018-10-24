import 'dart:async';
import 'dart:io';

import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/twitter_auth.dart';
import 'package:meta/meta.dart';

class EditProfileData {
  bool isArtist;
  String uid;
  String displayName;
  String facebookId;
  String twitterId;
  String bio;
  String countryIsoCode;
  File profilePicture;
  bool removeFacebook;
  bool removeTwitter;
}

class ProfileScreenBloc extends BlocBase {
  final AppConfig appConfig;
  final bool isArtist;

  StreamController<EditProfileData> _editProfileActionController =
      StreamController();

  StreamController _facebookAuthActionController = StreamController();
  StreamController _twitterAuthActionController = StreamController();
  StreamController<FacebookAuthResult> _facebookAuthResultController =
      StreamController();
  StreamController<TwitterAuthResult> _twitterAuthResultController =
      StreamController();

  Sink<EditProfileData> get editProfile => _editProfileActionController.sink;

  Sink get facebookAuth => _facebookAuthActionController.sink;

  Sink get twitterAuth => _twitterAuthActionController.sink;

  Stream<FacebookAuthResult> get facebookAuthResult =>
      _facebookAuthResultController.stream;

  Stream<TwitterAuthResult> get twitterAuthResult =>
      _twitterAuthResultController.stream;

  ProfileScreenBloc({
    @required this.appConfig,
    @required this.isArtist,
  }) {
    _facebookAuthActionController.stream
        .listen((_) => _handleFacebookAuthAction());
    _twitterAuthActionController.stream
        .listen((_) => _handleTwitterAuthAction());
  }

  @override
  void dispose() {
    _editProfileActionController.close();
    _facebookAuthActionController.close();
    _twitterAuthActionController.close();
    _facebookAuthResultController.close();
    _twitterAuthResultController.close();
  }

  void _handleFacebookAuthAction() async {
    final facebookAuth = FacebookAuth();
    final result = await facebookAuth.facebookAuth();
    _facebookAuthResultController.add(result);
  }

  void _handleTwitterAuthAction() async {
    final twitterAuth = TwitterAuth(appConfig: appConfig);
    final result = await twitterAuth.twitterAuth();
    _twitterAuthResultController.add(result);
  }
}
