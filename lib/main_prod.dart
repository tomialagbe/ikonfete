import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/facebook/facebook.dart';
import 'package:ikonfetemobile/main.dart';
import 'package:ikonfetemobile/twitter/twitter_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  SystemChrome.setPreferredOrientations(
    <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ],
  );

  final firebaseApp = await FirebaseApp.configure(
    name: "ikonfete",
    options: FirebaseOptions(
      googleAppID: Platform.isIOS
          ? "1:504427487731:ios:75be1ef2cbdac210"
          : "1:504427487731:android:49880b1f76da2ca7",
      projectID: "ikonfete-server",
      gcmSenderID: "504427487731",
      apiKey: "AIzaSyCJz_OBOjuxtd6h9AW-l0s_6jYixna-RRI",
    ),
  );

  var sharedPreferences = await SharedPreferences.getInstance();
  final currentUser = await FirebaseAuth.instance.currentUser();
  var configuredApp = AppConfig(
    appName: "Ikonfete",
    flavorName: "production",
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
    serverBaseUrl: "https://ikonfete-server.appspot.com",
    child:
        IkonfeteApp(preferences: sharedPreferences, currentUser: currentUser),
  );
  runApp(configuredApp);
}
