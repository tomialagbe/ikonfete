import 'dart:async';

import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/team.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class FanTeamSelectionBloc extends BlocBase {
  final AppConfig appConfig;

  BehaviorSubject<String> _searchArtistTeamActionController =
      BehaviorSubject<String>();
  StreamController<List<Team>> _searchArtistTeamResultController =
      StreamController.broadcast();

  /// A stream that takes the uid of an artist
  StreamController<Team> _loadArtistForTeamActionController =
      StreamController.broadcast();
  StreamController<Pair<Team, Artist>> _loadArtistForTeamResultController =
      StreamController.broadcast();

  /// A stream that takes a pair of - the team id and the fan id and adds the fan to the
  /// team
  StreamController<Pair<String, String>> _addFanToTeamActionController =
      StreamController<Pair<String, String>>();

  StreamController<bool> _addFanToTeamResultController =
      StreamController.broadcast();

  Sink<String> get searchArtistTeam => _searchArtistTeamActionController.sink;

  Stream<List<Team>> get searchArtistTeamResult =>
      _searchArtistTeamResultController.stream;

  Sink<Team> get loadArtistForTeam => _loadArtistForTeamActionController.sink;

  Stream<Pair<Team, Artist>> get loadArtistForTeamResult =>
      _loadArtistForTeamResultController.stream;

  Sink<Pair<String, String>> get addFanToTeam =>
      _addFanToTeamActionController.sink;

  Stream<bool> get addFanToTeamResult => _addFanToTeamResultController.stream;

  FanTeamSelectionBloc({@required this.appConfig}) {
    _searchArtistTeamActionController.stream
        .debounce(Duration(milliseconds: 500))
        .listen(_searchArtistTeams);
    _loadArtistForTeamActionController.stream.listen(_loadArtistForTeam);
    _addFanToTeamActionController.stream
        .listen((r) => _addFanToTeam(r.first, r.second));
  }

  @override
  void dispose() {
    _searchArtistTeamActionController.close();
    _searchArtistTeamResultController.close();
    _loadArtistForTeamActionController.close();
    _loadArtistForTeamResultController.close();
    _addFanToTeamActionController.close();
    _addFanToTeamResultController.close();
  }

  void _searchArtistTeams(String query) async {
    final artistApi = ArtistApi(appConfig.serverBaseUrl);
    List<Team> teams;
    try {
      if (query.trim().isEmpty) {
        teams = await artistApi.getTeams(1, 20);
      } else {
        teams = await artistApi.searchTeams(query, 1, 20);
      }
      _searchArtistTeamResultController.add(teams);
    } on ApiException catch (e) {
      _searchArtistTeamResultController.addError(e.message);
    }
  }

  void _loadArtistForTeam(Team team) async {
    final artistApi = ArtistApi(appConfig.serverBaseUrl);
    try {
      final artist = await artistApi.findByUID(team.artistUid);
      _loadArtistForTeamResultController.add(Pair.from(team, artist));
    } on ApiException catch (e) {
      _loadArtistForTeamResultController.addError(e.message);
    }
  }

  void _addFanToTeam(String teamId, String fanId) async {
    final artistApi = ArtistApi(appConfig.serverBaseUrl);
    try {
      final success = await artistApi.addFanToTeam(teamId, fanId);
      _addFanToTeamResultController.add(success);
    } on ApiException catch (e) {
      _addFanToTeamResultController.addError(e.message);
    }
  }
}
