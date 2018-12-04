import 'package:flutter/material.dart';
import 'package:ikonfetemobile/facebook/facebook.dart';
import 'package:ikonfetemobile/twitter/twitter_config.dart';
import 'package:meta/meta.dart';

class AppConfig extends InheritedWidget {
  AppConfig({
    @required this.appName,
    @required this.flavorName,
    @required this.facebookConfig,
    @required this.twitterConfig,
    @required this.serverBaseUrl,
//    @required this.firebaseStorage,
    @required Widget child,
  }) : super(child: child);

  final String appName;
  final String flavorName;
  final FacebookConfig facebookConfig;
  final TwitterConfig twitterConfig;
  final String serverBaseUrl;
//  final FirebaseStorage firebaseStorage;

  static AppConfig of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppConfig);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
