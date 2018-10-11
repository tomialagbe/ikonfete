import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/model/pending_verification.dart';

class PendingVerificationApi extends Api {
  PendingVerificationApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<bool> createPendingVerification(
      PendingVerification pendingVerification) async {
    final url = "$apiBaseUrl/pending_verifications";
    final headers = {"Content-Type": "application/json"};
    final map = pendingVerification.toJson()..remove("id");
    final body = json.encode(map);
    try {
      final response = await http.post(url, headers: headers, body: body);
      switch (response.statusCode) {
        case 201:
          Map responseData = json.decode(response.body);
          return responseData["success"];
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
