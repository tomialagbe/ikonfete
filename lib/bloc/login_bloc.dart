import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/api/fan.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/auth_utils.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:meta/meta.dart';

class LoginBloc extends BlocBase {
  final AppConfig appConfig;

  String _email;
  String _password;

  final bool isArtist;

  StreamController<String> _emailController = StreamController<String>();
  StreamController<String> _passwordController = StreamController<String>();

  StreamController<AuthActionRequest> _loginActionController =
      StreamController<AuthActionRequest>();
  StreamController<LoginResult> _loginResultController =
      StreamController<LoginResult>();

  Sink<String> get email => _emailController.sink;

  Sink<String> get password => _passwordController.sink;

  Sink<AuthActionRequest> get loginAction => _loginActionController.sink;

  Stream<LoginResult> get loginResult => _loginResultController.stream;

  Sink<LoginResult> get _loginResult => _loginResultController.sink;

  LoginBloc({
    @required this.isArtist,
    @required this.appConfig,
  }) {
    _emailController.stream.listen((val) => _email = val.trim());
    _passwordController.stream.listen((val) => _password = val.trim());
    _loginActionController.stream.listen(_handleLoginRequest);
  }

  @override
  void dispose() {
    _emailController.close();
    _passwordController.close();
    _loginActionController.close();
    _loginResultController.close();
  }

  void _handleLoginRequest(AuthActionRequest request) async {
    LoginResult result;
    if (request.isEmailProvider) {
      result = await _emailLogin(request);
    } else {
      result = await _facebookLogin(request);
    }
    _loginResult.add(result);
  }

  Future<LoginResult> _emailLogin(AuthActionRequest request) async {
    final authResult = LoginResult(request);
    try {
      final firebaseUser = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      // get the artist or fan
      if (request.isArtist) {
        final artistApi = ArtistApi(appConfig.serverBaseUrl);
        final artist = await artistApi.findByUID(firebaseUser.uid);
        authResult.artist = artist;
      } else {
        final fanApi = FanApi(appConfig.serverBaseUrl);
        final fan = await fanApi.findByUID(firebaseUser.uid);
        authResult.fan = fan;
      }
      authResult.firebaseUser = firebaseUser;
      return authResult;
    } on PlatformException catch (e) {
      switch (e.code) {
        case "Error 17020":
          authResult.errorMessage = "Network Error.";
          break;
        case "Error 17009":
        default:
          authResult.errorMessage = "Invalid email or password.";
          break;
      }
      return authResult;
    } on ApiException catch (e) {
      authResult.errorMessage = e.message;
      return authResult;
    } on Exception {
      authResult.errorMessage = "An unknown error occurred";
      return authResult;
    }
  }

  Future<LoginResult> _facebookLogin(AuthActionRequest request) async {
    try {
      final authResult = LoginResult(request);
      final facebookLogin = FacebookLogin();
      facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
      await facebookLogin.logOut();
      final result = await facebookLogin.logInWithReadPermissions(
        [
          'email',
          'public_profile',
          'user_posts',
          'user_events',
        ],
      );
      if (result.status != FacebookLoginStatus.loggedIn) {
        authResult.errorMessage =
            result.status == FacebookLoginStatus.cancelledByUser
                ? "Login Cancelled"
                : result.errorMessage;
        return authResult;
      }

      final firebaseUser = await FirebaseAuth.instance
          .signInWithFacebook(accessToken: result.accessToken.token);

      // find the user
      if (request.isArtist) {
        final artistApi = ArtistApi(appConfig.serverBaseUrl);
        final artist = await artistApi.findByUID(firebaseUser.uid);
        authResult.artist = artist;
      } else {
        final fanApi = FanApi(appConfig.serverBaseUrl);
        final fan = await fanApi.findByUID(firebaseUser.uid);
        authResult.fan = fan;
      }
      authResult.firebaseUser = firebaseUser;
      return authResult;
    } on ApiException catch (e) {
      return LoginResult(request)..errorMessage = e.message;
    } on PlatformException catch (e) {
      return LoginResult(request)..errorMessage = e.message;
    } on Exception catch (e) {
      return LoginResult(request)..errorMessage = e.toString();
    }
  }
}
