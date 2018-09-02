import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/facebook/facebook.dart';

class FacebookGraph {
  final String _baseGraphUrl = "https://graph.facebook.com/v2.8/";
  final Token token;

  FacebookGraph(this.token);

  Future<PublicProfile> me(List<String> fields) async {
    String _fields = fields.join(",");
    final http.Response response = await http
        .get("$_baseGraphUrl/me?fields=$_fields&access_token=${token.access}");
    return new PublicProfile.fromMap(json.decode(response.body));
  }
}

Future<Stream<String>> _server() async {
  final StreamController<String> onCode = new StreamController();
  HttpServer server =
      await HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, 8080);
  server.listen((HttpRequest request) async {
    final String code = request.uri.queryParameters["code"];
    request.response
      ..statusCode = 200
      ..headers.set("Content-Type", ContentType.HTML.mimeType)
      ..write("<html>You can now close this window</html>");
    await request.response.close();
    await server.close(force: true);
    onCode.add(code);
    await onCode.close();
  });
  return onCode.stream;
}

Future<Token> getToken(String appId, String appSecret) async {
  Stream<String> onCode = await _server();
  String url =
      "https://www.facebook.com/dialog/oauth?client_id=$appId&redirect_uri=http://localhost:8080/&scope=public_profile";

  ///
  /// Implementation using a webviewFlugin (full page)
  ///
  final FlutterWebviewPlugin webviewPlugin = new FlutterWebviewPlugin();
  webviewPlugin.launch(
      url /*, clearCache: true, clearCookies: true*/); // Uncomment to force new login via Facebook
  final String code = await onCode.first;
  webviewPlugin.close();

  final http.Response response = await http.get(
      "https://graph.facebook.com/v2.2/oauth/access_token?client_id=$appId&redirect_uri=http://localhost:8080/&client_secret=$appSecret&code=$code");
  return new Token.fromMap(json.decode(response.body));
}
