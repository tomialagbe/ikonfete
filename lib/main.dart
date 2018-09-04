import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/onboarding_screen.dart';
import 'package:ikonfetemobile/splash_screen.dart';

void main() => runApp(new IkonfeteApp());

class IkonfeteApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  IkonfeteAppState createState() {
    return IkonfeteAppState();
  }
}

class IkonfeteAppState extends State<IkonfeteApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
//      supportedLocales: [Locale("en", ""), Locale("es", ""), Locale("pt", "")],
      supportedLocales: [
        Locale("en", ""),
      ],
      onGenerateTitle: (context) {
        return AppLocalizations.of(context).title;
      },
      home: SplashScreen(),
      routes: <String, WidgetBuilder>{
        "/onboarding": (ctx) => OnBoardingScreen()
      },
    );
  }
}
