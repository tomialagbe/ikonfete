import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';

class ArtistPendingVerificationBloc extends BlocBase {
  final AppConfig appConfig;
  final String uid;

  StreamController _loadUserActionController = StreamController();
  StreamController<Pair<FirebaseUser, Artist>> _loadUserResultController =
      StreamController.broadcast();

  StreamController _logoutActionController = StreamController.broadcast();
  StreamController<bool> _logoutResultController = StreamController.broadcast();

  Sink get logoutAction => _logoutActionController.sink;

  Stream<bool> get logoutResult => _logoutResultController.stream;

  Sink get loadUserAction => _loadUserActionController.sink;

  Stream<Pair<FirebaseUser, Artist>> get loadUserResult =>
      _loadUserResultController.stream;

  ArtistPendingVerificationBloc({
    @required this.uid,
    @required this.appConfig,
  }) {
    _loadUserActionController.stream.listen((_) => _handleLoadUserAction());
    _logoutActionController.stream.listen((_) => _handleLogout());
  }

  @override
  void dispose() {
    _loadUserActionController.close();
    _loadUserResultController.close();
    _logoutActionController.close();
    _logoutResultController.close();
  }

  void _handleLoadUserAction() async {
    try {
      final firebaseUser = await FirebaseAuth.instance.currentUser();
      if (firebaseUser != null) {
        final artistApi = ArtistApi(appConfig.serverBaseUrl);
        final artist = await artistApi.findByUID(firebaseUser.uid);
        _loadUserResultController.add(Pair.from(firebaseUser, artist));
      }
    } on ApiException catch (e) {
      _loadUserResultController.addError(e.message);
    }
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _logoutResultController.add(true);
    } on PlatformException {
      _logoutResultController.add(false);
    }
  }
}
