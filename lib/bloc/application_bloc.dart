import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/api/fan.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInitState {
  bool isOnBoarded = false;

//  bool isArtist = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;
  Artist _artist;
  Fan _fan;

  set fan(Fan fan) {
    _artist = null;
    _fan = fan;
  }

  set artist(Artist artist) {
    _fan = null;
    _artist = artist;
  }

  Fan get fan => _fan;

  Artist get artist => _artist;

  bool get isProfileSetup => artist != null
      ? !StringUtils.isNullOrEmpty(artist.username)
      : !StringUtils.isNullOrEmpty(fan.username);

  bool get isFanTeamSetup =>
      fan != null && !StringUtils.isNullOrEmpty(fan.currentTeamId);

  bool get isArtist => _artist != null;

  void logout() {
    artist = null;
    fan = null;
    currentUser = null;
    isLoggedIn = false;
  }
}

class ApplicationBloc implements BlocBase {
  final AppConfig appConfig;
  AppInitState initState = AppInitState();
  StreamController _logoutActionController = StreamController.broadcast();
  StreamController<bool> _logoutResultController = StreamController.broadcast();

  @override
  void dispose() {
    _logoutActionController.close();
    _logoutResultController.close();
  }

  ApplicationBloc({@required this.appConfig});

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
    final state = AppInitState()..isOnBoarded = isOnBoarded;
    final currUser = await FirebaseAuth.instance.currentUser();
    state.isLoggedIn = currUser != null;
    state.currentUser = currUser;
    // at this stage, artist and fan are null, so we need to get the preferences

    try {
      if (state.isLoggedIn) {
        // check if this user is an artist
        Artist artist;
        Fan fan;
        artist =
            await ArtistApi(appConfig.serverBaseUrl).findByUID(currUser.uid);
        if (artist == null) {
          fan = await FanApi(appConfig.serverBaseUrl).findByUID(currUser.uid);
          if (fan == null) {
            throw new Exception("Invalid Application State");
          } else {
            state.fan = fan;
          }
        } else {
          state.artist = artist;
        }
      }
    } on ApiException catch (e) {
      throw e;
    }

    this.initState = state;
    return state;
  }
}
