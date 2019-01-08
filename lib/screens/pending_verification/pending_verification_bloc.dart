import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';

abstract class PendingVerificationEvents {}

class LoadUser extends PendingVerificationEvents {
  final String uid;

  LoadUser(this.uid);
}

class PendingVerificationState {
  final bool isLoading;
  final FirebaseUser firebaseUser;
  final Artist artist;
  final bool hasError;
  final String errorMessage;

  PendingVerificationState({
    @required this.isLoading,
    @required this.firebaseUser,
    @required this.artist,
    @required this.hasError,
    @required this.errorMessage,
  });

  factory PendingVerificationState.initial() {
    return PendingVerificationState(
      isLoading: true,
      artist: null,
      firebaseUser: null,
      hasError: false,
      errorMessage: null,
    );
  }

  bool get hasData => artist != null && firebaseUser != null;

  PendingVerificationState copyWith({
    bool isLoading,
    FirebaseUser firebaseUser,
    Artist artist,
    bool hasError,
    String errorMessage,
  }) {
    return PendingVerificationState(
      isLoading: isLoading ?? this.isLoading,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      artist: artist ?? this.artist,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  PendingVerificationState withError(String errorMessage) {
    return copyWith(
        isLoading: false, hasError: true, errorMessage: errorMessage);
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is PendingVerificationState &&
      runtimeType == other.runtimeType &&
      isLoading == other.isLoading &&
      firebaseUser == other.firebaseUser &&
      artist == other.artist;

  @override
  int get hashCode =>
      isLoading.hashCode ^ firebaseUser.hashCode ^ artist.hashCode;
}

class PendingVerificationBloc
    extends Bloc<PendingVerificationEvents, PendingVerificationState> {
  final AppConfig appConfig;

  PendingVerificationBloc({@required this.appConfig});

  @override
  PendingVerificationState get initialState =>
      PendingVerificationState.initial();

  @override
  Stream<PendingVerificationState> mapEventToState(
      PendingVerificationState state, PendingVerificationEvents event) async* {
    if (event is LoadUser) {
      try {
        final result = await _loadUser(event.uid);
        yield state.copyWith(
            isLoading: false,
            firebaseUser: result.first,
            artist: result.second);
      } on ApiException catch (e) {
        yield state.withError(e.message);
      }
    }
  }

  Future<Pair<FirebaseUser, Artist>> _loadUser(String uid) async {
    final firebaseUser = await FirebaseAuth.instance.currentUser();
    if (firebaseUser == null) {
      throw ApiException("User not found");
    }
    final artistApi = ArtistApi(appConfig.serverBaseUrl);
    final artist = await artistApi.findByUID(firebaseUser.uid);
    if (artist == null) {
      throw ApiException("User not found");
    }
    return Pair.from(firebaseUser, artist);
  }
}
