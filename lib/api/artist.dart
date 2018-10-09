import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/model/artist.dart';

class ArtistApi extends Api {
  ArtistApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<Artist> findByUID(String uid) async {
    final url = "$apiBaseUrl/artists/${Uri.encodeComponent(uid)}";
    try {
      http.Response response = await http.get(url);
      switch (response.statusCode) {
        case 200:
          Map data = json.decode(response.body);
          final artist = new Artist()..fromJson(data["artist"]);
          return artist;
          break;
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
