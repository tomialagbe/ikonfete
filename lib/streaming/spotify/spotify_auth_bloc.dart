import 'dart:async';

import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/streaming/spotify/models.dart';
import 'package:ikonfetemobile/streaming/spotify/spotify.dart';
import 'package:ikonfetemobile/streaming/spotify/spotify_web_api.dart';
import 'package:rxdart/rxdart.dart';

class SpotifyAuthBloc extends BlocBase {
  SpotifyApi _spotifyApi;

  ReplaySubject<SpotifyUser> _spotifyAuthResult = ReplaySubject<SpotifyUser>();
  StreamController _spotifyAuthAction = StreamController();

  Stream<SpotifyUser> get spotifyAuthResult => _spotifyAuthResult.stream;

  SpotifyAuthBloc() {
    _spotifyApi = SpotifyApi();
    _spotifyAuthAction.stream.listen((_) => _handleSpotifyAuthAction());
  }

  @override
  void dispose() {
    _spotifyAuthResult.close();
  }

  void authorizeSpotify() => _spotifyAuthAction.add(null);

  void _handleSpotifyAuthAction() async {
    try {
      final spotifyUser = await _spotifyApi.authenticate();
      _spotifyAuthResult.add(spotifyUser);
    } on SpotifyApiError catch (e) {
      _spotifyAuthResult.addError(e.message);
    }
  }
}
