import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/auth_utils.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/utils/strings.dart';
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

  factory AppState.initial(SharedPreferences preferences) {
    // get shared prefs

    return AppState(
      isOnBoarded: preferences.getBool(PreferenceKeys.isOnBoarded) ?? false,
      isLoggedIn: false,
      currentUser: null,
      isProfileSetup: false,
      isFanTeamSetup: false,
      isArtist: preferences.getBool(PreferenceKeys.isArtist) ?? false,
      artistOrFan: null,
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

  AppBloc({@required this.preferences});

  @override
  AppState get initialState => AppState.initial(preferences);

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
      yield state.copyWith(
          artistOrFan: null, isLoggedIn: false, currentUser: null);
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
