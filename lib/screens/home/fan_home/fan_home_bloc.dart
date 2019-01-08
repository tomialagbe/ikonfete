import 'package:bloc/bloc.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/api/teams.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/screens/home/fan_home/fan_home_events.dart';
import 'package:ikonfetemobile/screens/home/fan_home/fan_home_state.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:meta/meta.dart';

class FanHomeBloc extends Bloc<FanHomeEvent, FanHomeState> {
  final AppConfig appConfig;

  FanHomeBloc({@required this.appConfig});

  @override
  FanHomeState get initialState => FanHomeState.initial();

  @override
  void onTransition(Transition<FanHomeEvent, FanHomeState> transition) {
    super.onTransition(transition);

    if (transition.event is FanHomeLoadArtistEvent) {
      dispatch(_FanHomeLoadArtistEvent(
          currentTeamId:
              (transition.event as FanHomeLoadArtistEvent).currentTeamId));
    }

    if (transition.event is _FanHomeLoadArtistEvent &&
        transition.nextState.isArtistLoaded) {
      // check facebook auth after artist loads
      dispatch(CheckFacebookAuth());
    }

    if (transition.event is CheckFacebookAuth &&
        transition.nextState.isFacebookAuthorized) {
      // TODO: send command to load feed
    }
  }

  @override
  Stream<FanHomeState> mapEventToState(
      FanHomeState state, FanHomeEvent event) async* {
    if (event is FanHomeLoadArtistEvent) {
      yield state.copyWith(isArtistLoading: true);
    }

    if (event is _FanHomeLoadArtistEvent) {
      final teamId = event.currentTeamId;
      try {
        final artist = await _loadArtistByTeamId(teamId);
        yield state.copyWith(
            artist: artist,
            isArtistLoading: false,
            isArtistLoaded: true,
            loadArtistError: null,
            loadArtistFailed: false);
      } on Exception catch (e) {
        yield state.copyWith(
            loadArtistFailed: true,
            isArtistLoading: false,
            loadArtistError: e.toString(),
            isArtistLoaded: false);
      }
    }

    // check facebook auth status
    if (event is CheckFacebookAuth) {
      try {
        bool ok = await _checkFacebookAuth();
        yield state.copyWith(isFacebookAuthorized: ok, facebookAuthError: null);
      } on Exception catch (e) {
        yield state.copyWith(
            isFacebookAuthorized: false, facebookAuthError: e.toString());
      }
    }

    if (event is DoFacebookAuth) {
      try {
        final authResult = await _doFacebookAuth();
        yield state.copyWith(
          facebookAccessToken: authResult.accessToken,
          isFacebookAuthorized: true,
          facebookAuthError: null,
        );
      } on Exception catch (e) {
        yield state.copyWith(
            isFacebookAuthorized: false, facebookAuthError: e.toString());
      }
    }

    if (event is SwitchTab) {
      var activeTab = FanHomeActiveTab.ArtistFeed;
      switch (event.newTab) {
        case 0:
          activeTab = FanHomeActiveTab.ArtistFeed;
          break;
        case 1:
          activeTab = FanHomeActiveTab.TeamFeed;
          break;
        case 2:
        default:
          activeTab = FanHomeActiveTab.Leaderboard;
          break;
      }
      yield state.copyWith(activeTab: activeTab);
    }
    // TODO: handle other event types
  }

  Future<Artist> _loadArtistByTeamId(String teamId) async {
    final teamApi = TeamApi(appConfig.serverBaseUrl);
    final artistApi = ArtistApi(appConfig.serverBaseUrl);
    final team = await teamApi.getTeamByID(teamId);
    if (team == null) {
      throw ApiException("Artist team not found");
    }
    final artist = await artistApi.findByUID(team.artistUid);
    if (artist == null) {
      throw ApiException("Artist not found");
    }
    return artist;
  }

  Future<bool> _checkFacebookAuth() async {
    final fbAuth = FacebookAuth();
    if (!(await fbAuth.isLoggedIn())) {
      return false;
    }
    return true;
  }

  Future<FacebookAuthResult> _doFacebookAuth() async {
    final fbAuth = FacebookAuth();
    final fbAuthResult = fbAuth.facebookAuth();
    return fbAuthResult;
  }
}

class _FanHomeLoadArtistEvent extends FanHomeEvent {
  final String currentTeamId;

  _FanHomeLoadArtistEvent({@required this.currentTeamId});
}
