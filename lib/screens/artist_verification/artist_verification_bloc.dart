import 'package:bloc/bloc.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/pending_verification.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/model/pending_verification.dart';
import 'package:ikonfetemobile/screens/artist_verification/artist_verification_events.dart';
import 'package:ikonfetemobile/screens/artist_verification/artist_verification_state.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/utils/twitter_auth.dart';
import 'package:ikonfetemobile/utils/types.dart';
import 'package:meta/meta.dart';

class _SubmitVerification extends ArtistVerificationEvent {}

class ArtistVerificationBloc
    extends Bloc<ArtistVerificationEvent, ArtistVerificationState> {
  final AppConfig appConfig;
  final String uid;

  ArtistVerificationBloc({@required this.appConfig, @required this.uid});

  @override
  ArtistVerificationState get initialState {
    print("Calling INITIAL");
    return ArtistVerificationState.initial();
  }

  @override
  void onTransition(
      Transition<ArtistVerificationEvent, ArtistVerificationState> transition) {
    super.onTransition(transition);
    if (transition.event is SubmitVerification) {
      dispatch(_SubmitVerification());
    }
  }

  @override
  Stream<ArtistVerificationState> mapEventToState(
      ArtistVerificationState state, ArtistVerificationEvent event) async* {
    if (event is AddBio) {
      yield state.copyWith(bio: event.bio);
    }

    try {
      if (event is AddFacebook) {
        final facebookResult = await _addFacebook();
        if (facebookResult.success) {
          yield state.copyWith(
              isLoading: false,
              hasError: false,
              facebookId: facebookResult.facebookUID);
        } else {
          yield state.withError(facebookResult.errorMessage);
        }
      }

      if (event is AddTwitter) {
        final tresult = await _addTwitter();
        if (tresult.success) {
          yield state.copyWith(
              isLoading: false,
              hasError: false,
              twitterId: tresult.twitterUID,
              twitterUsername: tresult.twitterUsername);
        } else {
          yield state.withError(tresult.errorMessage);
        }
      }
    } on Exception catch (e) {
      yield state.withError(e.toString());
    }

    if (event is SubmitVerification) {
      yield state.copyWith(isLoading: true);
    }

    if (event is _SubmitVerification) {
      if (StringUtils.isNullOrEmpty(state.facebookId)) {
        yield state.withError("Your Facebook Id is required");
      } else if (StringUtils.isNullOrEmpty(state.twitterUsername)) {
        yield state.withError("Your Twitter username is required");
      } else {
        final result = await _submitPendingVerification(state);
        yield state.copyWith(
            isLoading: false, pendingVerificationResult: result);
      }
    }
  }

  Future<FacebookAuthResult> _addFacebook() async {
    final fbAuth = FacebookAuth();
    final fbResult = await fbAuth.facebookAuth(
        loginBehaviour: FacebookLoginBehavior.nativeWithFallback);
    return fbResult;
  }

  Future<TwitterAuthResult> _addTwitter() async {
    final twitterAuth = TwitterAuth(appConfig: appConfig);
    final tResult = await twitterAuth.twitterAuth();
    return tResult;
  }

  Future<Pair<bool, String>> _submitPendingVerification(
      ArtistVerificationState state) async {
    try {
      final pendingVerification = PendingVerification()
        ..uid = uid
        ..bio = state.bio
        ..facebookId = state.facebookId
        ..twitterId = state.twitterId;
      final pendingVerificationApi =
          PendingVerificationApi(appConfig.serverBaseUrl);

      final success = await pendingVerificationApi
          .createPendingVerification(pendingVerification);
      return Pair.from(success, null);
    } on ApiException catch (e) {
      return Pair.from(false, e.message);
    }
  }
}
