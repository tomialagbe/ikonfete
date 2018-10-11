import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/api/fan.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitState {
  bool isOnBoarded = false;
  bool isArtist = false;
  bool isLoggedIn = false;
  bool isProfileSetup = false;
  bool isArtistVerified = false;
  bool isArtistPendingVerification = false;
  bool isFanTeamSetup = false;
  String uid;
  String name;
}

class ApplicationBloc implements BlocBase {
  final AppConfig appConfig;
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

  ApplicationBloc({@required this.appConfig}) {
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
    state.isLoggedIn = currUser != null;

    bool isFanTeamSetup = false;
    bool isArtistVerified = false;
    bool isArtistPendingVerification = false;
    bool isProfileSetup = false;
    try {
      if (state.isLoggedIn) {
        if (isArtist) {
          final artist =
              await ArtistApi(appConfig.serverBaseUrl).findByUID(currUser.uid);
          isArtistVerified = artist.isVerified;
          isArtistPendingVerification = artist.isPendingVerification;
          isProfileSetup = !StringUtils.isNullOrEmpty(artist.username);
        } else {
          final fan =
              await FanApi(appConfig.serverBaseUrl).findByUID(currUser.uid);
          isFanTeamSetup = fan.currentTeamId.trim().isNotEmpty;
          isProfileSetup = !StringUtils.isNullOrEmpty(fan.username);
        }
      }
    } on ApiException catch (e) {
      throw e;
    }

    state.name = currUser != null ? currUser.displayName : "";
    state.isFanTeamSetup = isFanTeamSetup;
    state.uid = currUser != null ? currUser.uid : null;
    state.isArtistVerified = isArtistVerified;
    state.isArtistPendingVerification = isArtistPendingVerification;
    state.isProfileSetup = isProfileSetup;
    return state;
  }
}
