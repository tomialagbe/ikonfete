import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/routes.dart' as routes;
import 'package:ikonfetemobile/screens/splash.dart';

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
    final appConfig = AppConfig.of(context);
    final routeMap = routes.appRoutes(appConfig);
    return BlocProvider<ApplicationBloc>(
      bloc: ApplicationBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "SanFranciscoDisplay",
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
        onGenerateRoute: (settings) {
          final name = settings.name;
          final widget = routeMap[name];
          return CupertinoPageRoute(builder: (_) => widget);
        },
      ),
    );
  }
}
