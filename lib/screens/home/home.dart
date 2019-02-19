import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfetemobile/main_bloc.dart';
import 'package:ikonfetemobile/screens/home/artist_home/artist_home.dart';
import 'package:ikonfetemobile/screens/home/fan_home/fan_home.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

Screen homeScreen() {
  return Screen(
    title: "HOME",
    contentBuilder: (BuildContext context) {
      final appBloc = BlocProvider.of<AppBloc>(context);
      return BlocBuilder<AppEvent, AppState>(
        bloc: appBloc,
        builder: (BuildContext ctx, AppState appState) {
          if (appState.isArtist) {
            return artistHomeScreen(ctx);
          } else {
            return fanHomeScreen(ctx);
          }
        },
      );
    },
  );
}
