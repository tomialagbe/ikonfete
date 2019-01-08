import 'package:bloc/bloc.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/model/auth_type.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';

abstract class ActivationEvent {}

class ActivationCodeEntered extends ActivationEvent {
  final String code;
  final bool isArtist;

  ActivationCodeEntered({@required this.code, @required this.isArtist});
}

class ActivateUser extends ActivationEvent {
  final bool isArtist;
  final String uid;

  ActivateUser({@required this.isArtist, @required this.uid});
}

class _ActivateUser extends ActivationEvent {
  final bool isArtist;
  final String uid;

  _ActivateUser({@required this.isArtist, @required this.uid});
}

class ActivationState {
  final bool isLoading;
  final String activationCode;
  final Pair<bool, String> activationResult;

  ActivationState({
    @required this.isLoading,
    @required this.activationCode,
    @required this.activationResult,
  });

  factory ActivationState.initial() {
    return ActivationState(
      isLoading: false,
      activationCode: null,
      activationResult: null,
    );
  }

  ActivationState copyWith({
    bool isLoading,
    String activationCode,
    Pair<bool, String> activationResult,
  }) {
    return ActivationState(
      isLoading: isLoading ?? this.isLoading,
      activationCode: activationCode ?? this.activationCode,
      activationResult: activationResult ?? this.activationResult,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is ActivationState &&
      runtimeType == other.runtimeType &&
      isLoading == other.isLoading &&
      activationCode == other.activationCode &&
      activationResult == other.activationResult;

  @override
  int get hashCode =>
      isLoading.hashCode ^ activationCode.hashCode ^ activationResult.hashCode;
}

class ActivationBloc extends Bloc<ActivationEvent, ActivationState> {
  final AppConfig appConfig;

  ActivationBloc({@required this.appConfig});

  @override
  ActivationState get initialState => ActivationState.initial();

  @override
  void onTransition(Transition<ActivationEvent, ActivationState> transition) {
    super.onTransition(transition);
    final event = transition.event;
    if (event is ActivateUser) {
      dispatch(_ActivateUser(isArtist: event.isArtist, uid: event.uid));
    }
  }

  @override
  Stream<ActivationState> mapEventToState(
      ActivationState state, ActivationEvent event) async* {
    if (event is ActivateUser) {
      yield state.copyWith(isLoading: true);
    }

    if (event is ActivationCodeEntered) {
      final code = event.code;
      yield state.copyWith(activationCode: code);
    }

    if (event is _ActivateUser) {
      final result = await _activateUser(state, event.uid, event.isArtist);
      yield state.copyWith(activationResult: result, isLoading: false);
    }
  }

  Future<Pair<bool, String>> _activateUser(
      ActivationState state, String uid, bool isArtist) async {
    final authApi = AuthApiFactory.authApi(appConfig.serverBaseUrl,
        isArtist ? AuthUserType.artist : AuthUserType.fan);
    try {
      bool ok = await authApi.activateUser(uid, state.activationCode);
      return Pair.from(ok, null);
    } on ApiException catch (e) {
      return Pair.from(false, e.message);
    } on Exception catch (e) {
      return Pair.from(false, e.toString());
    }
  }
}
