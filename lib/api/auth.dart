import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/auth_type.dart';
import 'package:ikonfetemobile/model/fan.dart';

class AuthApiFactory {
  static AuthApi authApi(String apiBaseUrl, AuthUserType type) {
    switch (type) {
      case AuthUserType.artist:
        return ArtistAuthApi(apiBaseUrl);
      case AuthUserType.fan:
      default:
        return FanAuthApi(apiBaseUrl);
    }
  }
}

abstract class AuthApi<T> extends Api {
  AuthApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<T> signup(String name, String email, String password);

  Future<bool> activateUser(String uid, String activationCode) async {
    final url =
        "${this.apiBaseUrl}/activate_user?uid=${Uri.encodeComponent(uid)}&activationCode=${Uri.encodeComponent(activationCode)}";
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

  Future<bool> setupUserProfile(
      String uid, String username, String profilePictureUrl,
      [bool isArtist = true]) async {
    final url = "${this.apiBaseUrl}/setup_profile";
    final headers = {"Content-Type": "application/json"};
    final body = {
      "uid": uid,
      "username": username,
      "profilePictureUrl": profilePictureUrl,
      "isArtist": isArtist,
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
    } on ApiException catch (e) {
      throw e;
    } on Exception {
      throw ApiException("A network error occurred");
    }
  }

  Future<bool> resendActivationCode(String uid) async {
    final url =
        "${this.apiBaseUrl}/resend_activation?uid=${Uri.encodeComponent(uid)}";
    final response = await http.get(url);
    switch (response.statusCode) {
      case 200:
        Map responseData = json.decode(response.body);
        return responseData["success"];
        break;
      default:
        final err = ApiError()..fromJson(json.decode(response.body));
        throw ApiException(err.error);
    }
  }
}

class ArtistAuthApi extends AuthApi<Artist> {
  ArtistAuthApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<Artist> _signupArtist(
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

  @override
  Future<Artist> signup(String name, String email, String password) {
    return _signupArtist(name, email, password);
  }
}

class FanAuthApi extends AuthApi<Fan> {
  FanAuthApi(String apiBaseUrl) : super(apiBaseUrl);

  @override
  Future<Fan> signup(String name, String email, String password) {
    return _signupFan(name, email, password);
  }

  Future<Fan> _signupFan(String name, String email, String password) async {
    final url = "${this.apiBaseUrl}/create_fan";
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
          final fan = Fan();
          fan.fromJson(responseData);
          return fan;
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
}
