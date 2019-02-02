import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ikonfetemobile/db_provider.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/auth_utils.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/utils/types.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AppEvent {}

class OnBoardDone extends AppEvent {
  final bool isArtist;

  OnBoardDone({@required this.isArtist});
}

class SwitchMode extends AppEvent {
  final bool isArtist;

  SwitchMode({@required this.isArtist});
}

class LoginDone extends AppEvent {
  final LoginResult loginResult;

  LoginDone({@required this.loginResult});
}

class Signout extends AppEvent {}

class FanSignupDone extends AppEvent {
  final Fan fan;

  FanSignupDone(this.fan);
}

class AppState {
  final bool isOnBoarded;
  final bool isLoggedIn;
  final FirebaseUser currentUser;
  final bool isProfileSetup;
  final bool isFanTeamSetup;
  final bool isArtist;
  final ExclusivePair<Artist, Fan> artistOrFan;

  AppState({
    this.isOnBoarded,
    this.isLoggedIn,
    this.currentUser,
    this.isProfileSetup,
    this.isFanTeamSetup,
    this.isArtist,
    this.artistOrFan,
  });

  String get uid => currentUser != null ? currentUser.uid : null;

  factory AppState.initial(SharedPreferences preferences,
      FirebaseUser currentUser, ExclusivePair<Artist, Fan> artistOrFan) {
    // get shared prefs
    final isArtist = preferences.getBool(PreferenceKeys.isArtist) ?? false;
    final isOnBoarded =
        preferences.getBool(PreferenceKeys.isOnBoarded) ?? false;
    final isLoggedIn = preferences.getBool(PreferenceKeys.isLoggedIn) ?? false;
    final isProfileSetup = artistOrFan == null
        ? false
        : (isArtist
            ? !StringUtils.isNullOrEmpty(artistOrFan.first.username)
            : !StringUtils.isNullOrEmpty(artistOrFan.second.username));
    final isFanTeamSetup = isArtist
        ? false
        : (artistOrFan == null
            ? false
            : !StringUtils.isNullOrEmpty(artistOrFan.second.currentTeamId));

    return AppState(
      isOnBoarded: isOnBoarded,
      isLoggedIn: isLoggedIn,
      currentUser: currentUser,
      isProfileSetup: isProfileSetup,
      isFanTeamSetup: isFanTeamSetup,
      isArtist: isArtist,
      artistOrFan: artistOrFan,
    );
  }

  AppState copyWith({
    bool isOnBoarded,
    bool isLoggedIn,
    FirebaseUser currentUser,
    bool isProfileSetup,
    bool isFanTeamSetup,
    bool isArtist,
    ExclusivePair<Artist, Fan> artistOrFan,
  }) {
    return AppState(
      isOnBoarded: isOnBoarded ?? this.isOnBoarded,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      currentUser: currentUser ?? this.currentUser,
      isProfileSetup: isProfileSetup ?? this.isProfileSetup,
      isFanTeamSetup: isFanTeamSetup ?? this.isFanTeamSetup,
      isArtist: isArtist ?? this.isArtist,
      artistOrFan: artistOrFan ?? this.artistOrFan,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is AppState &&
      runtimeType == other.runtimeType &&
      isOnBoarded == other.isOnBoarded &&
      isLoggedIn == other.isLoggedIn &&
      currentUser == other.currentUser &&
      isProfileSetup == other.isProfileSetup &&
      isFanTeamSetup == other.isFanTeamSetup &&
      isArtist == other.isArtist &&
      artistOrFan == other.artistOrFan;

  @override
  int get hashCode =>
      isOnBoarded.hashCode ^
      isLoggedIn.hashCode ^
      currentUser.hashCode ^
      isProfileSetup.hashCode ^
      isFanTeamSetup.hashCode ^
      isArtist.hashCode ^
      artistOrFan.hashCode;
}

class AppBloc extends Bloc<AppEvent, AppState> {
  final SharedPreferences preferences;
  final FirebaseUser initialCurrentUser;
  final ExclusivePair<Artist, Fan> initialCurrentArtistOrFan;

  AppBloc(
      {@required this.preferences,
      @required this.initialCurrentUser,
      @required this.initialCurrentArtistOrFan});

  @override
  AppState get initialState => AppState.initial(
      preferences, initialCurrentUser, initialCurrentArtistOrFan);

  @override
  Stream<AppState> mapEventToState(AppState state, AppEvent event) async* {
    if (event is OnBoardDone) {
      bool isArtist = event.isArtist;
      preferences.setBool(PreferenceKeys.isOnBoarded, true);
      preferences.setBool(PreferenceKeys.isArtist, isArtist);
      yield state.copyWith(isOnBoarded: true, isArtist: isArtist);
    }

    if (event is SwitchMode) {
      bool isArtist = event.isArtist;
      preferences.setBool(PreferenceKeys.isArtist, isArtist);
      yield state.copyWith(isArtist: isArtist);
    }

    if (event is Signout) {
      await _signOut();
      await preferences.setBool(PreferenceKeys.isLoggedIn, false);
      await preferences.remove(PreferenceKeys.uid);
      await DbProvider.db.clearCurrentArtistOrFan();
      final newState = AppState.initial(preferences, null, null);
      yield newState.copyWith(isLoggedIn: false);
    }

    if (event is LoginDone) {
      final isArtist = event.loginResult.isArtist;
      final artistOrFan = isArtist
          ? ExclusivePair<Artist, Fan>.withFirst(event.loginResult.artist)
          : ExclusivePair<Artist, Fan>.withSecond(event.loginResult.fan);
      final isFanTeamSetup = isArtist ||
          !StringUtils.isNullOrEmpty(artistOrFan.second.currentTeamId);
      final isProfileSetup = isArtist
          ? !StringUtils.isNullOrEmpty(artistOrFan.first.username)
          : !StringUtils.isNullOrEmpty(artistOrFan.second.username);
      final uid = isArtist ? artistOrFan.first.uid : artistOrFan.second.uid;

      await preferences.setBool(PreferenceKeys.isLoggedIn, true);
      await preferences.setString(PreferenceKeys.uid, uid);
      if (isArtist) {
        await DbProvider.db.setCurrentArtist(artistOrFan.first);
      } else {
        await DbProvider.db.setCurrentFan(artistOrFan.second);
      }

      yield state.copyWith(
        artistOrFan: artistOrFan,
        isArtist: event.loginResult.isArtist,
        currentUser: event.loginResult.firebaseUser,
        isFanTeamSetup: isFanTeamSetup,
        isProfileSetup: isProfileSetup,
        isLoggedIn: true,
      );
    }

    if (event is FanSignupDone) {
      final firebaseUser = await FirebaseAuth.instance.currentUser();
      final artistOrFan = ExclusivePair<Artist, Fan>.withSecond(event.fan);
      final isFanTeamSetup =
          !StringUtils.isNullOrEmpty(event.fan.currentTeamId);
      final isProfileSetup = !StringUtils.isNullOrEmpty(event.fan.username);
      await DbProvider.db.setCurrentFan(event.fan);

      yield state.copyWith(
        artistOrFan: artistOrFan,
        isArtist: false,
        currentUser: firebaseUser,
        isFanTeamSetup: isFanTeamSetup,
        isProfileSetup: isProfileSetup,
        isLoggedIn: true,
      );
    }
  }

  Future _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
