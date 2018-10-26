import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/profile.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/utils/twitter_auth.dart';
import 'package:ikonfetemobile/utils/upload_helper.dart';
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
  String profilePictureUrl;
  String oldProfilePictureUrl;
  bool removeFacebook;
  bool removeTwitter;
}

class ProfileScreenBloc extends BlocBase {
  final AppConfig appConfig;
  final bool isArtist;

  StreamController<EditProfileData> _editProfileActionController =
      StreamController();
  StreamController<bool> _editProfileResult = StreamController();

  StreamController _facebookAuthActionController = StreamController();
  StreamController _twitterAuthActionController = StreamController();
  StreamController<FacebookAuthResult> _facebookAuthResultController =
      StreamController();
  StreamController<TwitterAuthResult> _twitterAuthResultController =
      StreamController();

  Sink<EditProfileData> get editProfile => _editProfileActionController.sink;

  Stream<bool> get edtProfileResult => _editProfileResult.stream;

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
    _editProfileActionController.stream.listen(_handleEditProfileAction);
  }

  @override
  void dispose() {
    _editProfileActionController.close();
    _facebookAuthActionController.close();
    _twitterAuthActionController.close();
    _facebookAuthResultController.close();
    _twitterAuthResultController.close();
    _editProfileResult.close();
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

  void _handleEditProfileAction(EditProfileData data) async {
    try {
      if (data.profilePicture != null) {
        // delete the old profilePicture
        final uploadHelper = CloudStorageUploadHelper();
        try {
          if (!StringUtils.isNullOrEmpty(data.oldProfilePictureUrl)) {
            uploadHelper.deleteProfilePicture(
                appConfig.firebaseStorage, data.uid);
          }
        } on PlatformException catch (e) {} // if deletion fails, do nothing

        // upload a new profile picture, if one was specified
        final uploadResult = await uploadHelper.uploadProfilePicture(
            appConfig.firebaseStorage, data.uid, data.profilePicture);
        data.profilePictureUrl = uploadResult.fileDownloadUrl;
      }

      // make call to update profile api
      final profileApi = ProfileApi(appConfig.serverBaseUrl);
      bool updated = await profileApi.updateProfile(data);
      _editProfileResult.add(updated);
    } on ApiException catch (e) {
      _editProfileResult.addError(e.message);
    } on PlatformException catch (e) {
      _editProfileResult.addError(e.message);
    } on Exception catch (e) {
      _editProfileResult.addError(e.toString());
    }
  }
}
