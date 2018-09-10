import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class UserSignupProfileBloc extends BlocBase {
  String _uname;
  File _profilePic;

  final AppConfig appConfig;
  final String uid;

  StreamController<String> _usernameController = StreamController<String>();
  StreamController<File> _profilePictureController = StreamController<File>();
  StreamController _actionController = StreamController();
  StreamController<Pair<bool, String>> _actionResultController =
      StreamController<Pair<bool, String>>();

  Stream<String> get _username => _usernameController.stream;

  Sink<String> get username => _usernameController.sink;

  Stream<File> get _profilePicture => _profilePictureController.stream;

  Sink<File> get profilePicture => _profilePictureController.sink;

  Stream get _action => _actionController.stream;

  Sink get action => _actionController.sink;

  Stream<Pair<bool, String>> get actionResult => _actionResultController.stream;

  Sink<Pair<bool, String>> get _actionResult => _actionResultController.sink;

  UserSignupProfileBloc({
    @required this.appConfig,
    @required this.uid,
  }) {
    _username.listen((val) => _uname = val);
    _profilePicture.listen((val) => _profilePic = val);
    _action.listen((_) => _handleProfileUpdate());
  }

  @override
  void dispose() {
    _usernameController.close();
    _profilePictureController.close();
    _actionController.close();
    _actionResultController.close();
  }

  void _handleProfileUpdate() async {
    final querySnapshots = await Firestore.instance
        .collection("artists")
        .where("username", isEqualTo: _uname)
        .limit(1)
        .getDocuments();
    if (querySnapshots.documents.isNotEmpty) {
      // duplicate username
      _actionResult.add(Pair.from(false, "This username is already taken"));
    } else {
      String profilePicUrl = "";
      if (_profilePic != null) {
        // save the profile picture, make api call to update the firebase user with the username and profile picture url
        final imageId = Uuid().v1();
        final fileExtension = extension(_profilePic.path);

        StorageReference ref = appConfig.firebaseStorage
            .ref()
            .child("profile_pictures")
            .child("${uid}_$imageId$fileExtension");
        final uploadTask = ref.putFile(_profilePic, StorageMetadata());
        final snapshot = await uploadTask.future;
        profilePicUrl = snapshot.downloadUrl.toString();
      }

      // make api call to update firebase user with username and profile picture url
      final authApi = AuthApi(appConfig.serverBaseUrl);
      try {
        final ok = await authApi.setupArtistProfile(uid, _uname, profilePicUrl);
        if (ok) {
          _actionResult.add(Pair.from(true, null));
        } else {
          _actionResult.add(Pair.from(false, "An unknown error occrurred"));
        }
      } on ApiException catch (e) {
        _actionResult.add(Pair.from(false, e.message));
      }
    }
  }
}
