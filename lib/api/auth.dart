import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/model/artist.dart';

class AuthApi extends Api {
  AuthApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<Artist> signupArtist(
      String name, String email, String password) async {
    final url = "${this.apiBaseUrl}/create_artist";
    Map data = {
      "name": name,
      "email": email,
      "password": password,
    };
    final headers = {
      "Content-Type": "application/json",
    };
    try {
      http.Response response =
          await http.post(url, body: json.encode(data), headers: headers);
      switch (response.statusCode) {
        case 200:
          Map responseData = json.decode(response.body);
          final artist = Artist();
          artist.fromJson(responseData);
          return artist;
        default:
          Map responseData = json.decode(response.body);
          final err = ApiError();
          err.fromJson(responseData);
          throw ApiException(err.error);
      }
    } on Exception {
      throw ApiException("A network error occurred.");
    }
  }

  Future<bool> activateUser(String uid, String activationCode) async {
    final url =
        "${this.apiBaseUrl}/activate_user?uid=$uid&activationCode=$activationCode";
    final response = await http.get(url);
    switch (response.statusCode) {
      case 200:
        Map responseData = json.decode(response.body);
        return responseData["success"];
        break;
      default:
        final err = ApiError();
        err.fromJson(json.decode(response.body));
        throw ApiException(err.error);
    }
  }

  Future<bool> setupArtistProfile(
      String uid, String username, String profilePictureUrl) async {
    final url = "${this.apiBaseUrl}/setup_profile";
    final headers = {"Content-Type": "application/json"};
    final body = {
      "uid": uid,
      "username": username,
      "profilePictureUrl": profilePictureUrl,
    };
    try {
      http.Response response =
          await http.post(url, headers: headers, body: json.encode(body));
      switch (response.statusCode) {
        case 200:
          Map responseData = json.decode(response.body);
          return responseData["success"];
        default:
          final err = ApiError();
          err.fromJson(json.decode(response.body));
          throw ApiException(err.error);
      }
    } on Exception catch (e) {
      throw ApiException("A network error occurred");
    }
  }
}
