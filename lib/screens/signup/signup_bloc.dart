import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/model/auth_type.dart';
import 'package:ikonfetemobile/model/auth_utils.dart';
import 'package:ikonfetemobile/screens/signup/signup_events.dart';
import 'package:ikonfetemobile/screens/signup/signup_state.dart';
import 'package:meta/meta.dart';

class _EmailSignup extends SignupEvent {
  final bool isArtist;

  _EmailSignup({@required this.isArtist});
}

class _FacebookSignup extends SignupEvent {
  final bool isArtist;

  _FacebookSignup({@required this.isArtist});
}

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AppConfig appConfig;

  SignupBloc({
    @required this.appConfig,
  });

  @override
  SignupState get initialState => SignupState.initial();

  @override
  void onTransition(Transition<SignupEvent, SignupState> transition) {
    final event = transition.event;
    if (event is EmailSignup) {
      dispatch(_EmailSignup(isArtist: event.isArtist));
    }

    if (event is FacebookSignup) {
      dispatch(_FacebookSignup(isArtist: event.isArtist));
    }
  }

  @override
  Stream<SignupState> mapEventToState(
      SignupState state, SignupEvent event) async* {
    if (event is NameEntered) {
      yield state.copyWith(name: event.name);
    }
    if (event is EmailEntered) {
      yield state.copyWith(email: event.email);
    }
    if (event is PasswordEntered) {
      yield state.copyWith(password: event.password);
    }

    if (event is EmailSignup || event is FacebookSignup) {
      yield state.copyWith(isLoading: true);
    }

    if (event is _EmailSignup) {
      final signupResult = await _emailSignup(state, event.isArtist);
      yield state.copyWith(isLoading: false, signupResult: signupResult);
    }

    if (event is _FacebookSignup) {
      final signupResult = await _facebookSignup(state, event.isArtist);
      yield state.copyWith(isLoading: false, signupResult: signupResult);
    }
  }

  Future<AuthResult> _emailSignup(SignupState state, bool isArtist) async {
    final authActionRequest = AuthActionRequest(
        provider: AuthProvider.email,
        userType: isArtist ? AuthUserType.artist : AuthUserType.fan);

    final authApi = AuthApiFactory.authApi(
        appConfig.serverBaseUrl, authActionRequest.userType);
    final signupResult = AuthResult(request: authActionRequest);

    try {
      final authResult =
          await authApi.signup(state.name, state.email, state.password);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: state.email, password: state.password);
      if (authActionRequest.isArtist) {
        signupResult.artist = authResult;
      } else {
        signupResult.fan = authResult;
      }
      return signupResult;
    } on Exception catch (e) {
      signupResult.errorMessage = e.toString();
      return signupResult;
    }
  }

  Future<AuthResult> _facebookSignup(SignupState state, bool isArtist) async {
    final authRequest = AuthActionRequest(
        provider: AuthProvider.facebook,
        userType: isArtist ? AuthUserType.artist : AuthUserType.fan);
    final authApi =
        AuthApiFactory.authApi(appConfig.serverBaseUrl, authRequest.userType);

    try {
      final facebookLogin = FacebookLogin();
      facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
      await facebookLogin.logOut();
      final facebookLoginResult = await facebookLogin.logInWithReadPermissions(
        [
          'email',
          'public_profile',
          'user_posts',
          'user_events',
        ],
      );

      if (facebookLoginResult.status != FacebookLoginStatus.loggedIn) {
        return AuthResult.error(
            authRequest,
            facebookLoginResult.status == FacebookLoginStatus.cancelledByUser
                ? "Login Cancelled"
                : facebookLoginResult.errorMessage);
      }

//      final firebaseUser = await FirebaseAuth.instance.signInWithFacebook(
//          accessToken: facebookLoginResult.accessToken.token);
      final facebookAuthCredential = FacebookAuthProvider.getCredential(
          accessToken: facebookLoginResult.accessToken.token);
      final firebaseUser = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
      if (firebaseUser == null) {
        return AuthResult.error(authRequest, "Facebook Sign up failed");
      }

      final signupResult = AuthResult(request: authRequest);
      final artistOrFan = await authApi.facebookSignup(
          firebaseUser.uid, facebookLoginResult.accessToken.userId);
      if (artistOrFan.isFirst) {
        signupResult.artist = artistOrFan.first;
      } else {
        signupResult.fan = artistOrFan.second;
      }
      return signupResult;
    } on PlatformException catch (e) {
      return AuthResult.error(authRequest, e.message);
    } on Exception catch (e) {
      return AuthResult.error(authRequest, e.toString());
    }
  }
}
