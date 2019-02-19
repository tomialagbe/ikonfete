import 'package:bloc/bloc.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/settings.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/model/settings.dart';
import 'package:ikonfetemobile/streaming/deezer/deezer_api.dart';
import 'package:meta/meta.dart';

abstract class SettingsEvent {}

class LoadSettingsEvent extends SettingsEvent {
  final String uid;

  LoadSettingsEvent(this.uid);
}

class EnableDeezerEvent extends SettingsEvent {}

class SettingsState {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;

  final Settings settings;

  SettingsState({
    @required this.isLoading,
    @required this.hasError,
    @required this.errorMessage,
    @required this.settings,
  });

  factory SettingsState.initial() {
    return SettingsState(
      isLoading: true,
      hasError: false,
      errorMessage: null,
      settings: Settings.empty(),
    );
  }

  SettingsState copyWith({
    bool isLoading,
    bool hasError,
    String errorMessage,
    Settings settings,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      settings: settings ?? this.settings,
    );
  }

  SettingsState withError(String errorMessage) {
    return copyWith(
        errorMessage: errorMessage, hasError: true, isLoading: false);
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is SettingsState &&
      runtimeType == other.runtimeType &&
      settings == other.settings;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      hashCode.hashCode ^
      errorMessage.hashCode ^
      settings.hashCode;
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AppConfig appConfig;

  SettingsBloc({@required this.appConfig});

  @override
  SettingsState get initialState => SettingsState.initial();

  @override
  Stream<SettingsState> mapEventToState(
      SettingsState state, SettingsEvent event) async* {
    try {
      if (event is LoadSettingsEvent) {
        final settings = (await loadSettings(event.uid)) ?? Settings.empty();
        yield state.copyWith(
            isLoading: false, hasError: false, settings: settings);
      }

      if (event is EnableDeezerEvent) {
        final deezerApi = DeezerApi();
        bool success = await deezerApi.authenticate();
        if (success) {
          final deezerUser = await deezerApi.getCurrentUser();
          final Settings settings = state.settings;
          settings.deezerUserId = "${deezerUser.id}";
          yield state.copyWith(
              hasError: false, isLoading: false, settings: settings);
        }
      }
    } on ApiException catch (e) {
      yield state.withError(e.message);
    } on Exception catch (e) {
      yield state.withError(e.toString());
    }
  }

  Future<Settings> loadSettings(String uid) async {
    final settingsApi = SettingsApi(appConfig.serverBaseUrl);
    final settings = await settingsApi.findByUID(uid);
    return settings;
  }
}

/*import 'dart:async';

import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/settings.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/settings.dart';
import 'package:ikonfetemobile/streaming/deezer/deezer_auth_bloc.dart';
import 'package:ikonfetemobile/streaming/spotify/spotify_auth_bloc.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:meta/meta.dart';

class SettingsBloc extends BlocBase {
  AppConfig appConfig;

  DeezerAuthBloc deezerAuthBloc;
  SpotifyAuthBloc spotifyAuthBloc;

  StreamController<String> _loadSettingsAction = StreamController<String>();
  StreamController<Settings> _loadSettingsResult = StreamController<Settings>();

  StreamController<Settings> _saveSettingsAction = StreamController<Settings>();
  StreamController<Settings> _saveSettingsResult = StreamController<Settings>();

  Stream<Settings> get loadSettingsResult => _loadSettingsResult.stream;
  Stream<Settings> get saveSettingsResult => _saveSettingsResult.stream;

  SettingsBloc({
    @required this.appConfig,
    @required this.deezerAuthBloc,
    @required this.spotifyAuthBloc,
  }) {
    _loadSettingsAction.stream.listen(_handleLoadSettingsAction);
    _saveSettingsAction.stream.listen(_handleSaveSettingsAction);
  }

  @override
  void dispose() {
    _loadSettingsAction.close();
    _loadSettingsResult.close();
    _saveSettingsAction.close();
    _saveSettingsResult.close();
  }

  void loadSettings(String uid) => _loadSettingsAction.add(uid);

  void updateSettings(Settings settings) => _saveSettingsAction.add(settings);

  void _handleLoadSettingsAction(String uid) async {
    try {
      final settingsApi = SettingsApi(appConfig.serverBaseUrl);
      final settings = await settingsApi.findByUID(uid);
      _loadSettingsResult.add(settings);
    } on ApiException catch (e) {
      _loadSettingsResult.addError(e.message);
    } on Exception catch (e) {
      _loadSettingsResult.addError(e.toString());
    }
  }

  void _handleSaveSettingsAction(Settings settings) async {
    try {
      final api = SettingsApi(appConfig.serverBaseUrl);
      Settings result;
      if (StringUtils.isNullOrEmpty(settings.id)) {
        // create new settings
        result = await api.createSettings(settings);
      } else {
        // update settings
        result = await api.updateSettings(settings.uid, settings);
      }
      _saveSettingsResult.add(result);
    } on ApiException catch (e) {
      _saveSettingsResult.addError(e.message);
    }
  }
}
*/
