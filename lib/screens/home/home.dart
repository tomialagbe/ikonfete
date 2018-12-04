import 'package:flutter/material.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/screens/home/artist_home.dart';
import 'package:ikonfetemobile/screens/home/fan_home.dart';
import 'package:ikonfetemobile/screens/home/fan_home_bloc.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';
import 'package:meta/meta.dart';

Screen homeScreen({@required bool isArtist}) {
  return Screen(
    title: "HOME",
    contentBuilder: (BuildContext context) {
      return isArtist
          ? ArtistHomeScreen()
          : BlocProvider<FanHomeBloc>(
              child: FanHomeScreen(),
              bloc: FanHomeBloc(appConfig: AppConfig.of(context)),
            );
    },
  );
}
