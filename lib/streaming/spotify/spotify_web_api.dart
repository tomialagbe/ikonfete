import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/streaming/spotify/models.dart';

class SpotifyApiError implements Exception {
  String status;
  String message;

  SpotifyApiError.fromJson(Map json) {
    Map err = json["error"];
    this
      ..status = err["status"]
      ..message = err["message"];
  }

  SpotifyApiError(this.message);
}

class SpotifyWebApi {
  final String baseUrl = "https://api.spotify.com";

  final String _accessToken;

  SpotifyWebApi(this._accessToken);

  Future<SpotifyUser> getCurrentUser() async {
    final url = "https://api.spotify.com/v1/me";
    final headers = {
      "Authorization": "Bearer $_accessToken",
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    final http.Response response = await http.get(url, headers: headers);
    switch (response.statusCode) {
      case 200:
        Map userData = json.decode(response.body);
        return SpotifyUser.fromMap(userData);
      default:
        Map responseData = json.decode(response.body);
        final err = SpotifyApiError.fromJson(responseData);
        throw err;
    }
  }
}
