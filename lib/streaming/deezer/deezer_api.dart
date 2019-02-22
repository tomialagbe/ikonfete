import 'dart:async';

import 'package:flutter/services.dart';

import 'models.dart';

class DeezerApi {
  static final DeezerApi _singleton = new DeezerApi._internal();

  final deezerMethodChannel = "ikonfete_deezer_method_channel";
  final deezerPlayerEventChannel = "ikonfete_deezer_player_event_channel";
  final deezerPlayerBufferEventChannel =
      "ikonfete_deezer_player_buffer_event_channel";

  MethodChannel _methodChannel;
  EventChannel _playerEventChannel;
  EventChannel _playerBufferEventChannel;

  StreamController<DeezerPlayerEvent> _playerEventStreamController;
  StreamController<DeezerBufferEvent> _playerBufferEventStreamController;

  factory DeezerApi() {
    return _singleton;
  }

  DeezerApi._internal() {
    _methodChannel = new MethodChannel(deezerMethodChannel);
    _playerEventChannel = new EventChannel(deezerPlayerEventChannel);
    _playerBufferEventChannel =
        new EventChannel(deezerPlayerBufferEventChannel);

    _playerEventStreamController = StreamController.broadcast();
    _playerBufferEventStreamController = StreamController.broadcast();
  }

  Stream<DeezerPlayerEvent> get playerEventStream =>
      _playerEventStreamController.stream;

  Stream<DeezerBufferEvent> get playerBufferEventStream =>
      _playerBufferEventStreamController.stream;

  Future<bool> authenticate() async {
    try {
      Map result = await _methodChannel.invokeMethod("authorize");
      if (result["success"]) {
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      return false;
    }
  }

  Future<bool> isSessionValid() async {
    try {
      bool isValid = await _methodChannel.invokeMethod("isSessionValid");
      return isValid;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  Future<String> getAccessToken() async {
    try {
      String accessToken = await _methodChannel.invokeMethod("getAccessToken");
      return accessToken;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  Future logout() async {
    try {
      await _methodChannel.invokeMethod("logout");
    } on PlatformException catch (e) {
      return;
    }
  }

  Future<DeezerUser> getCurrentUser() async {
    try {
      Map userData = await _methodChannel.invokeMethod("getCurrentUser");
      DeezerUser user = new DeezerUser.fromMap(userData);
      return user;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  Future<DeezerTrack> getTrack(int trackId) async {
    try {
      Map trackData =
          await _methodChannel.invokeMethod("getTrack", {"trackId": trackId});
      DeezerTrack track = new DeezerTrack.fromMap(trackData);
      return track;
    } on PlatformException catch (e) {
      throw e;
    }
  }

  Future<bool> initializeTrackPlayer() async {
    try {
      bool success = await _methodChannel.invokeMethod("initializeTrackPlayer");
      _playerEventChannel.receiveBroadcastStream().listen((dynamic data) {
        Map map = data as Map;
        final event = DeezerPlayerEvent.fromMap(map);
        _playerEventStreamController.add(event);
      }).onError((err) {
        // TODO: handle playback error
      });

      _playerBufferEventChannel.receiveBroadcastStream().listen((dynamic data) {
        Map map = data as Map;
        final event = DeezerBufferEvent.fromMap(map);
        _playerBufferEventStreamController.add(event);
      }).onError((err) {
        // TODO: handle event
      });
      return success;
    } on PlatformException catch (e) {
      if (e.code == "deezer_invalid_session") return false;
      throw e;
    }
  }

  Future closePlayer() async {
    try {
      await _methodChannel.invokeMethod("closePlayer");
    } on PlatformException {}
  }

  Future playTrack(int trackId) async {
    try {
      await _methodChannel.invokeMethod("playTrack", {"trackId": trackId});
    } on PlatformException {}
  }

  Future pause() async {
    try {
      await _methodChannel.invokeMethod("pause");
    } on PlatformException {}
  }

  Future resume() async {
    try {
      await _methodChannel.invokeMethod("resume");
    } on PlatformException {}
  }

  Future stop() async {
    try {
      await _methodChannel.invokeMethod("stop");
    } on PlatformException {}
  }
}
