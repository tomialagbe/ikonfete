import 'package:flutter/material.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/facebook/facebook.dart';
import 'package:ikonfetemobile/main.dart';
import 'package:ikonfetemobile/twitter/twitter_config.dart';

void main() {
  var configuredApp = AppConfig(
    appName: "Ikonfete",
    flavorName: "production",
    facebookConfig: FacebookConfig(
      appId: "",
      appSecret: "",
    ),
    // TODO: set these values
    twitterConfig: TwitterConfig(
      consumerKey: "",
      consumerSecret: "",
      accessToken: "",
      accessTokenSecret: "",
    ),
    child: IkonfeteApp(),
  );
  runApp(configuredApp);
}
