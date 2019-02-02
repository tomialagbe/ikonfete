import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/db_provider.dart';
import 'package:ikonfetemobile/facebook/facebook.dart';
import 'package:ikonfetemobile/main.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/twitter/twitter_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
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
          ? "1:915599328141:ios:75be1ef2cbdac210"
          : "1:915599328141:android:49880b1f76da2ca7",
      projectID: "ikonfete-dev",
      gcmSenderID: "915599328141",
      apiKey: "AIzaSyDfYJVgz85fds9XyoqbZhHsUOMTJuJwx6A",
    ),
  );

  await DbProvider.db.database; // init database
  final sharedPreferences = await SharedPreferences.getInstance();
  final currentUser = await FirebaseAuth.instance.currentUser();
  final uid = sharedPreferences.getString(PreferenceKeys.uid);
  var artistOrFan;
  if (uid != null) {
    artistOrFan = await DbProvider.db.getArtistOrFanByUid(uid);
  }

  var configuredApp = AppConfig(
    appName: "Ikonfete",
    flavorName: "development",
    facebookConfig: FacebookConfig(
      appId: "943663045673430",
      appSecret: "dfe9bb52af3633ebc7ddc5e722a4e9ea",
    ),
    twitterConfig: TwitterConfig(
      consumerKey: "HXmlUWQTdP6mIGUjcQIJZnc5h",
      consumerSecret: "yEkJVRH7BQW8ktrNcYfJqTmrRNmj7yG2FMtAatjtJ6AsIZ07CD",
      accessToken: "232707493-WuE4AfaUH6FZ4DP23dAFe6Aw4ta8mXD63oIyAXkB",
      accessTokenSecret: "dTdKFRrZScqgERhzLQnQEqrgkWNDag5T5yQF3ncAukS0h",
    ),
    serverBaseUrl: "http://104.248.166.222:8080",
    child: IkonfeteApp(
      preferences: sharedPreferences,
      currentUser: currentUser,
      currentArtistOrFan: artistOrFan,
    ),
  );
  runApp(configuredApp);
}
