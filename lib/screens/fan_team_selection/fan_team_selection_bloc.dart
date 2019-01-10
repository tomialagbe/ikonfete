import 'package:bloc/bloc.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/api/fan.dart';
import 'package:ikonfetemobile/api/teams.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/model/team.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

abstract class TeamSelectionEvent {}

class LoadFan extends TeamSelectionEvent {
  final String uid;

  LoadFan(this.uid);
}

class _LoadFan extends TeamSelectionEvent {
  final String uid;

  _LoadFan(this.uid);
}

class SearchQuery extends TeamSelectionEvent {
  final String query;

  SearchQuery(this.query);
}

class _SearchQuery extends TeamSelectionEvent {
  final String query;

  _SearchQuery(this.query);
}

class TeamSelected extends TeamSelectionEvent {
  final Team team;

  TeamSelected(this.team);
}

class _LoadArtistForTeam extends TeamSelectionEvent {
  final Team team;

  _LoadArtistForTeam(this.team);
}

class AddFanToTeam extends TeamSelectionEvent {
  final String teamId;
  final String fanUid;

  AddFanToTeam({@required this.teamId, @required this.fanUid});
}

class _AddFanToTeam extends TeamSelectionEvent {
  final String teamId;
  final String fanUid;

  _AddFanToTeam({@required this.teamId, @required this.fanUid});
}

class ClearSelectedTeam extends TeamSelectionEvent {}

class TeamSelectionState {
  final bool isLoading;
  final Fan fan;
  final List<Team> teams;
  final bool isSearching;
  final Team selectedTeam;
  final Artist selectedArtist;
  final bool showArtistModal;
  final bool hasError;
  final String errorMessage;
  final bool teamSelectionResult;

  TeamSelectionState({
    @required this.isLoading,
    @required this.fan,
    @required this.teams,
    @required this.isSearching,
    @required this.selectedTeam,
    @required this.selectedArtist,
    @required this.showArtistModal,
    @required this.hasError,
    @required this.errorMessage,
    @required this.teamSelectionResult,
  });

  factory TeamSelectionState.initial() {
    return TeamSelectionState(
      isLoading: false,
      fan: null,
      teams: [],
      isSearching: false,
      selectedTeam: null,
      selectedArtist: null,
      showArtistModal: false,
      hasError: false,
      errorMessage: null,
      teamSelectionResult: false,
    );
  }

  TeamSelectionState copyWith({
    bool isLoading,
    Fan fan,
    List<Team> teams,
    bool isSearching,
    Team selectedTeam,
    Artist selectedArtist,
    bool showArtistModal,
    bool hasError,
    String errorMessage,
    bool teamSelectionResult,
  }) {
    return TeamSelectionState(
      isLoading: isLoading ?? this.isLoading,
      fan: fan ?? this.fan,
      teams: teams ?? this.teams,
      isSearching: isSearching ?? this.isSearching,
      selectedTeam: selectedTeam ?? this.selectedTeam,
      selectedArtist: selectedArtist ?? this.selectedArtist,
      showArtistModal: showArtistModal ?? this.showArtistModal,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      teamSelectionResult: teamSelectionResult ?? this.teamSelectionResult,
    );
  }

  TeamSelectionState withError(String errorMessage) {
    return copyWith(
        isLoading: false,
        isSearching: false,
        hasError: true,
        showArtistModal: false,
        errorMessage: errorMessage);
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is TeamSelectionState &&
      runtimeType == other.runtimeType &&
      isLoading == other.isLoading &&
      fan == other.fan &&
      teams == other.teams &&
      isSearching == other.isSearching &&
      selectedTeam == other.selectedTeam &&
      selectedArtist == other.selectedArtist &&
      showArtistModal == other.showArtistModal &&
      hasError == other.hasError &&
      errorMessage == other.errorMessage &&
      teamSelectionResult == other.teamSelectionResult;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      teams.hashCode ^
      fan.hashCode ^
      isSearching.hashCode ^
      selectedTeam.hashCode ^
      selectedArtist.hashCode ^
      showArtistModal.hashCode ^
      hashCode.hashCode ^
      errorMessage.hashCode ^
      teamSelectionResult.hashCode;
}

class TeamSelectionBloc extends Bloc<TeamSelectionEvent, TeamSelectionState> {
  final AppConfig appConfig;

  TeamSelectionBloc({@required this.appConfig});

  @override
  TeamSelectionState get initialState => TeamSelectionState.initial();

  @override
  void onTransition(
      Transition<TeamSelectionEvent, TeamSelectionState> transition) {
    super.onTransition(transition);
    final event = transition.event;

    if (event is LoadFan) {
      dispatch(_LoadFan(event.uid));
    }

    if (event is SearchQuery) {
      dispatch(_SearchQuery(event.query));
    }

    if (event is TeamSelected) {
      dispatch(_LoadArtistForTeam(event.team));
    }

    if (event is AddFanToTeam) {
      dispatch(_AddFanToTeam(teamId: event.teamId, fanUid: event.fanUid));
    }
  }

  @override
  Stream<TeamSelectionEvent> transform(Stream<TeamSelectionEvent> events) {
    return (events as Observable<TeamSelectionEvent>)
        .debounce(Duration(milliseconds: 100));
  }

  // TODO: implement infinite scrolling list
  @override
  Stream<TeamSelectionState> mapEventToState(
      TeamSelectionState state, TeamSelectionEvent event) async* {
    if (event is LoadFan || event is AddFanToTeam) {
      yield state.copyWith(isLoading: true, hasError: false);
    }

    if (event is SearchQuery) {
      yield state.copyWith(isSearching: true, hasError: false);
    }

    if (event is TeamSelected) {
      yield state.copyWith(
          selectedTeam: event.team, isLoading: true, hasError: false);
    }

    if (event is ClearSelectedTeam) {
      yield TeamSelectionState.initial()
          .copyWith(fan: state.fan, teams: state.teams);
    }

    try {
      if (event is _LoadFan) {
        final fan = await _loadFan(event.uid);
        dispatch(SearchQuery(""));
        yield state.copyWith(isLoading: false, fan: fan, hasError: false);
      }

      if (event is _SearchQuery) {
        final teams = await _searchArtistTeams(event.query);
        yield state.copyWith(isSearching: false, teams: teams, hasError: false);
      }

      if (event is _LoadArtistForTeam) {
        final artist = await _loadArtistForTeam(event.team);
        yield state.copyWith(
            selectedArtist: artist.second,
            isLoading: false,
            hasError: false,
            showArtistModal: true);
      }

      if (event is _AddFanToTeam) {
        final fan = state.fan;
        final result = await _addFanToTeam(event.teamId, event.fanUid);
        fan.currentTeamId = event.teamId;
        final newState =
            TeamSelectionState.initial().copyWith(fan: fan, teams: state.teams);
        if (!result) {
          yield newState.copyWith(
            teamSelectionResult: false,
            isLoading: false,
            hasError: true,
            showArtistModal: false,
            errorMessage: "Failed to join team",
          );
        } else {
          yield newState.copyWith(
            isLoading: false,
            teamSelectionResult: true,
            hasError: false,
            showArtistModal: false,
          );
        }
      }
    } on ApiException catch (e) {
      yield state.withError(e.message);
    }
  }

  Future<Fan> _loadFan(String uid) async {
    try {
      final fanApi = FanApi(appConfig.serverBaseUrl);
      final fan = fanApi.findByUID(uid);
      if (fan == null) {
        throw ApiException("Fan not found");
      }
      return fan;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<Team>> _searchArtistTeams(String query) async {
    final teamApi = TeamApi(appConfig.serverBaseUrl);
    List<Team> teams;
    if (query.trim().isEmpty) {
      teams = await teamApi.getTeams(1, 20);
    } else {
      teams = await teamApi.searchTeams(query, 1, 20);
    }
    return teams;
  }

  Future<Pair<Team, Artist>> _loadArtistForTeam(Team team) async {
    final artistApi = ArtistApi(appConfig.serverBaseUrl);
    final artist = await artistApi.findByUID(team.artistUid);
    return Pair.from(team, artist);
  }

  Future<bool> _addFanToTeam(String teamId, String fanUid) async {
    final teamApi = TeamApi(appConfig.serverBaseUrl);
    final success = await teamApi.addFanToTeam(teamId, fanUid);
    return success;
  }
}
