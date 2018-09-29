import 'dart:async';

import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/repository/artist_repository.dart';

class FanTeamSelectionBloc extends BlocBase {
  StreamController<String> _searchArtistsActionController =
      StreamController<String>();

  FanTeamSelectionBloc() {
    _searchArtistsActionController.stream.listen(_searchArtists);
  }

  @override
  void dispose() {
    _searchArtistsActionController.close();
  }

  void _searchArtists(String query) async {
    final artistRepo = ArtistRepository();
  }
}
