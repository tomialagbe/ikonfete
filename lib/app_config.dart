import 'package:flutter/material.dart';
import 'package:ikonfetemobile/facebook/facebook.dart';
import 'package:ikonfetemobile/twitter/twitter.dart';
import 'package:meta/meta.dart';

class AppConfig extends InheritedWidget {
  AppConfig({
    @required this.appName,
    @required this.flavorName,
    @required this.facebookConfig,
    @required this.twitterConfig,
    @required Widget child,
  }) : super(child: child);

  final String appName;
  final String flavorName;
  final FacebookConfig facebookConfig;
  final TwitterConfig twitterConfig;

  static AppConfig of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AppConfig);
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;
}
