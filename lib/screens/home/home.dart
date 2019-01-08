import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/screens/home/artist_home.dart';
import 'package:ikonfetemobile/screens/home/fan_home/fan_home.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';
import 'package:meta/meta.dart';

Screen homeScreen({@required bool isArtist}) {
  return Screen(
    title: "HOME",
    contentBuilder: (BuildContext context) {
      final appBloc = BlocProvider.of<ApplicationBloc>(context);
      final currentTeamID = appBloc.initState.fan.currentTeamId;
      final fanUID = appBloc.initState.fan.uid;

      return isArtist
          ? ArtistHomeScreen()
          : FanHomeScreen(
              currentTeamID: currentTeamID,
              fanUID: fanUID,
              appConfig: appBloc.appConfig,
            );
//          : BlocProvider<FanHomeBloc>(
//              child: FanHomeScreen(),
//              bloc: FanHomeBloc(appConfig: AppConfig.of(context)),
//            );
    },
  );
}
