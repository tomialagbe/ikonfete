import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/model/fan.dart';

class FanApi extends Api {
  FanApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<Fan> findByUID(String uid) async {
    final url = "$apiBaseUrl/fans/${Uri.encodeComponent(uid)}";
    try {
      http.Response response = await http.get(url);
      switch (response.statusCode) {
        case 200:
          Map data = json.decode(response.body);
          final artist = new Fan()..fromJson(data["fan"]);
          return artist;
          break;
        case 404:
          return null;
        default:
          final apiErr = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(apiErr.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }
}
