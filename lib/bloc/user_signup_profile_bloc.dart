import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/auth_type.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/utils/upload_helper.dart';
import 'package:meta/meta.dart';

class UserSignupProfileBloc extends BlocBase {
  String _uname;
  File _profilePic;
  String _countryIsoCode;

  final AppConfig appConfig;
  final String uid;
  final bool isArtist;

  StreamController<String> _usernameController = StreamController<String>();
  StreamController<String> _countryController = StreamController<String>();
  StreamController<File> _profilePictureController = StreamController<File>();
  StreamController _actionController = StreamController();
  StreamController<Pair<bool, String>> _actionResultController =
      StreamController.broadcast();

  Stream<String> get _username => _usernameController.stream;

  Sink<String> get username => _usernameController.sink;

  Stream<String> get _countryCode => _countryController.stream;

  Sink<String> get countryCode => _countryController.sink;

  Stream<File> get _profilePicture => _profilePictureController.stream;

  Sink<File> get profilePicture => _profilePictureController.sink;

  Stream get _action => _actionController.stream;

  Sink get action => _actionController.sink;

  Stream<Pair<bool, String>> get actionResult => _actionResultController.stream;

  Sink<Pair<bool, String>> get _actionResult => _actionResultController.sink;

  UserSignupProfileBloc({
    @required this.appConfig,
    @required this.isArtist,
    @required this.uid,
  }) {
    _username.listen((val) => _uname = val);
    _profilePicture.listen((val) => _profilePic = val);
    _action.listen((_) => _handleProfileUpdate());
    _countryCode.listen((val) => _countryIsoCode = val);
  }

  @override
  void dispose() {
    _usernameController.close();
    _profilePictureController.close();
    _actionController.close();
    _actionResultController.close();
    _countryController.close();
  }

  void _handleProfileUpdate() async {
    final firebaseStorage = FirebaseStorage.instance;
    final uploadHelper = CloudStorageUploadHelper();
    String profilePicUrl = "";
    if (_profilePic != null) {
      try {
        final uploadResult = await uploadHelper.uploadProfilePicture(
            firebaseStorage, uid, _profilePic);
        profilePicUrl = uploadResult.fileDownloadUrl;
      } on PlatformException catch (e) {
        _actionResult.add(Pair.from(false, e.message));
        return;
      }
    }

    // make api call to update firebase user with username and profile picture url
    final authApi = AuthApiFactory.authApi(appConfig.serverBaseUrl,
        isArtist ? AuthUserType.artist : AuthUserType.fan);
    try {
      final ok = await authApi.setupUserProfile(
        uid,
        _uname,
        _countryIsoCode,
        profilePicUrl,
        isArtist,
      );
      if (ok) {
        _actionResult.add(Pair.from(true, null));
      } else {
        uploadHelper.deleteProfilePicture(firebaseStorage, uid);
        _actionResult.add(Pair.from(false, "An unknown error occrurred"));
      }
    } on ApiException catch (e) {
      uploadHelper.deleteProfilePicture(firebaseStorage, uid);
      _actionResult.add(Pair.from(false, e.message));
    } on Exception catch (e) {
      uploadHelper.deleteProfilePicture(firebaseStorage, uid);
      _actionResult.add(Pair.from(false, e.toString()));
    }
  }
}
