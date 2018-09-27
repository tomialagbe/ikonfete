import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/repository/artist_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitState {
  bool isOnBoarded = false;
  bool isArtist = false;
  bool isLoggedIn = false;
  bool isArtistVerified = false;
  bool isArtistPendingVerification = false;
  String uid;
}

class ApplicationBloc implements BlocBase {
  StreamController _logoutActionController = StreamController.broadcast();
  StreamController<bool> _logoutResultController =
      StreamController.broadcast<bool>();

  Sink get logoutAction => _logoutActionController.sink;

  Stream<bool> get logoutResult => _logoutResultController.stream;

  @override
  void dispose() {
    _logoutActionController.close();
    _logoutResultController.close();
  }

  ApplicationBloc() {
    _logoutActionController.stream.listen((_) => _handleLogout());
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _logoutResultController.add(true);
    } on PlatformException {
      _logoutResultController.add(false);
    }
  }

  Future<bool> doLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on PlatformException {
      return false;
    }
  }

  Future<AppInitState> getAppInitState() async {
    final prefs = await SharedPreferences.getInstance();
    final isOnBoarded = prefs.getBool(PreferenceKeys.isOnBoarded) ?? false;
    final isArtist = prefs.getBool(PreferenceKeys.isArtist) ?? false;
    final state = AppInitState()
      ..isArtist = isArtist
      ..isOnBoarded = isOnBoarded;
    final currUser = await FirebaseAuth.instance.currentUser();
    state.isLoggedIn =
        currUser != null && !currUser.isAnonymous && currUser.isEmailVerified;

    final artistRepo = ArtistRepository();
    bool isArtistVerified = false;
    bool isArtistPendingVerification = false;
    if (isArtist) {
      if (currUser != null) {
        final artist = await artistRepo.findByUid(currUser.uid);
        isArtistVerified = artist != null && artist.isVerified;
        isArtistPendingVerification =
            artist != null && artist.isPendingVerification;
      }
    }
    state.uid = currUser != null ? currUser.uid : null;
    state.isArtistVerified = isArtistVerified;
    state.isArtistPendingVerification = isArtistPendingVerification;
    return state;
  }
}
