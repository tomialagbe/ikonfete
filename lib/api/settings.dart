import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/model/settings.dart';

class SettingsApi extends Api {
  SettingsApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<Settings> findByUID(String uid) async {
    final url = "$apiBaseUrl/settings/${Uri.encodeComponent(uid)}";
    try {
      http.Response response = await http.get(url);
      switch (response.statusCode) {
        case 200:
          Map data = json.decode(response.body);
          final settings = new Settings()..fromJson(data["settings"]);
          return settings;
        case 404:
          return null;
        default:
          final apierr = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(apierr.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Settings> updateSettings(String uid, Settings settings) async {
    try {
      final url = "$apiBaseUrl/settings/${Uri.encodeComponent(uid)}";
      final headers = {
        "Content-Type": "application/json",
      };
      final body = settings.toJson();
      http.Response response =
          await http.put(url, headers: headers, body: body);
      switch (response.statusCode) {
        case 200:
          Map data = json.decode(response.body);
          final settings = new Settings()..fromJson(data["settings"]);
          return settings;
        default:
          final err = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(err.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Settings> createSettings(Settings settings) async {
    try {
      final url = "$apiBaseUrl/settings";
      final headers = {
        "Content-Type": "application/json",
      };
      final body = settings.toJson();
      final response =
          await http.post(url, headers: headers, body: json.encode(body));
      switch (response.statusCode) {
        case 200:
          Map data = json.decode(response.body);
          final settings = Settings()..fromJson(data["settings"]);
          return settings;
        default:
          final err = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(err.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }
}
