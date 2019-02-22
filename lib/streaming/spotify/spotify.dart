import 'package:flutter/services.dart';
import 'package:ikonfetemobile/streaming/spotify/models.dart';
import 'package:ikonfetemobile/streaming/spotify/spotify_web_api.dart';

class SpotifyApi {
  static final SpotifyApi _singleton = new SpotifyApi._internal();

  final spotifyMethodChannel = "ikonfete_spotify_method_channel";

  String _accessToken;
  MethodChannel _methodChannel;
  SpotifyWebApi _webApi;

  factory SpotifyApi() {
    return _singleton;
  }

  SpotifyApi._internal() {
    _methodChannel = new MethodChannel(spotifyMethodChannel);
  }

  Future<SpotifyUser> authenticate() async {
    try {
      Map result = await _methodChannel.invokeMethod("login");
      if (result.containsKey("success")) {
        bool success = result["success"];
        if (success) {
          _accessToken = result["access_token"];
          _webApi = SpotifyWebApi(_accessToken);
          return await _webApi.getCurrentUser();
        } else {
          throw SpotifyApiError("Spotify Auth Failed");
        }
      } else {
        throw SpotifyApiError("Spotify Auth Failed");
      }
    } on PlatformException catch (e) {
      throw e;
    } on Exception catch (e) {
      throw e;
    }
  }
}
