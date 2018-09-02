import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/twitter/twitter.dart';

String getOauthHeader(TwitterConfig config, http.Request request) {
  final nonce = _generateNonceString();
  final signature = _generateRequestSignature(request);
  final timestamp = new DateTime.now().millisecondsSinceEpoch / 1000;
  return "OAuth oauth_consumer_key=\"${config.consumerKey}\","
      "oauth_nonce=\"$nonce\""
      "oauth_signature=\"$signature\""
      "oauth_signature_method=\"HMAC-SHA1\""
      "oauth_timestamp=\"$timestamp\""
      "oauth_token=\"${config.accessToken}\""
      "oauth_version=\"1.0\"";
}

String _generateRequestSignature(http.Request httpRequest) {
  final method = httpRequest.method.toUpperCase();
  final url = httpRequest.url.scheme +
      httpRequest.url.host +
      "/" +
      httpRequest.url.pathSegments.join("/");
  return "";
}

String _generateNonceString() {
  return _randomString(42);
}

String _randomString(int length) {
  var rand = new Random();
  var codeUnits = new List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });

  return new String.fromCharCodes(codeUnits);
}
