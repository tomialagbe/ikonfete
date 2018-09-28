import 'dart:async';

import 'package:ikonfetemobile/bloc/bloc.dart';

class FanTeamSelectionBloc extends BlocBase {
  StreamController _searchArtistsActionController = StreamController();

  FanTeamSelectionBloc() {}

  @override
  void dispose() {
    _searchArtistsActionController.close();
  }
}
