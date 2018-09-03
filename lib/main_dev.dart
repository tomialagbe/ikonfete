import 'package:flutter/material.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/facebook/facebook.dart';
import 'package:ikonfetemobile/main.dart';
import 'package:ikonfetemobile/twitter/twitter_config.dart';

void main() {
  var configuredApp = AppConfig(
    appName: "Ikonfete",
    flavorName: "development",
    facebookConfig: FacebookConfig(
      appId: "263295877604129",
      appSecret: "6ea9654754e55f0a7c8920fca326b7c6",
    ),
    twitterConfig: TwitterConfig(
      consumerKey: "HXmlUWQTdP6mIGUjcQIJZnc5h",
      consumerSecret: "yEkJVRH7BQW8ktrNcYfJqTmrRNmj7yG2FMtAatjtJ6AsIZ07CD",
      accessToken: "232707493-WuE4AfaUH6FZ4DP23dAFe6Aw4ta8mXD63oIyAXkB",
      accessTokenSecret: "dTdKFRrZScqgERhzLQnQEqrgkWNDag5T5yQF3ncAukS0h",
    ),
    child: IkonfeteApp(),
  );
  runApp(configuredApp);
}
