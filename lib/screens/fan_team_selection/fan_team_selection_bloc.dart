import 'dart:async';

import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/team.dart';
import 'package:ikonfetemobile/repository/team_repository.dart';
import 'package:rxdart/rxdart.dart';

class FanTeamSelectionBloc extends BlocBase {
  BehaviorSubject<String> _searchArtistTeamActionController =
      BehaviorSubject<String>();
  StreamController<List<Team>> _searchArtistTeamResultController =
      StreamController.broadcast<List<Team>>();

  Sink<String> get searchArtistTeam => _searchArtistTeamActionController.sink;

  Stream<List<Team>> get searchArtistTeamResult =>
      _searchArtistTeamResultController.stream;

  FanTeamSelectionBloc() {
    _searchArtistTeamActionController.stream
        .debounce(Duration(milliseconds: 500))
        .listen(_searchArtistTeams);
  }

  @override
  void dispose() {
    _searchArtistTeamActionController.close();
    _searchArtistTeamResultController.close();
  }

  void _searchArtistTeams(String query) async {
    final teamRepo = TeamRepository();
    List<Team> teams;
    if (query.trim().isEmpty) {
      teams = (await teamRepo.findAllTeams(20)).items;
    } else {
      teams = (await teamRepo.searchTeamsByArtistName(query, 20));
    }
    _searchArtistTeamResultController.add(teams);
  }
}
