import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/auth_utils.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';

class SignupBloc implements BlocBase {
  final AppConfig appConfig;

  String _name;
  String _email;
  String _password;

  // handle names
  StreamController<String> _nameController = StreamController<String>();
  StreamController<String> _emailController = StreamController<String>();
  StreamController<String> _passwordController = StreamController<String>();
  StreamController<AuthActionRequest> _actionSignup =
      StreamController<AuthActionRequest>();

  StreamController<AuthResult> _signupResultController =
      StreamController.broadcast();

  StreamSink<String> get name => _nameController.sink;

  StreamSink<String> get email => _emailController.sink;

  StreamSink<String> get password => _passwordController.sink;

  StreamSink<AuthActionRequest> get signup => _actionSignup.sink;

  Sink<AuthResult> get _signupResult => _signupResultController.sink;

  Stream<AuthResult> get signupResult => _signupResultController.stream;

  SignupBloc(this.appConfig) {
    _nameController.stream.listen((val) => _name = val.trim());
    _emailController.stream.listen((val) => _email = val.trim());
    _passwordController.stream.listen((val) => _password = val.trim());
    _actionSignup.stream.listen(_handleSignupRequest);
  }

  @override
  void dispose() {
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    _actionSignup.close();
    _signupResultController.close();
  }

  void _handleSignupRequest(AuthActionRequest request) async {
    AuthResult result;
    if (request.isEmailProvider) {
      result = await _emailSignup(request);
    } else {
      result = await _facebookSignup(request);
    }
    _signupResult.add(result);
  }

  Future<AuthResult> _emailSignup(AuthActionRequest request) async {
    final authApi =
        AuthApiFactory.authApi(appConfig.serverBaseUrl, request.userType);
    final signupResult = AuthResult(request: request);
    try {
      final authResult = await authApi.signup(_name, _email, _password);
      if (request.isArtist) {
        signupResult.artist = authResult;
      } else {
        signupResult.fan = authResult;
      }
      return signupResult;
    } on ApiException catch (e) {
      signupResult.errorMessage = e.message;
      return signupResult;
    } on Exception catch (e) {
      signupResult.errorMessage = e.toString();
      return signupResult;
    }
  }

  Future<AuthResult> _facebookSignup(AuthActionRequest request) async {
    try {
      final signupResult = AuthResult(request: request);
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
        signupResult.errorMessage =
            facebookLoginResult.status == FacebookLoginStatus.cancelledByUser
                ? "Login Cancelled"
                : facebookLoginResult.errorMessage;
        return signupResult;
      }

      final firebaseUser = await FirebaseAuth.instance.signInWithFacebook(
          accessToken: facebookLoginResult.accessToken.token);
      if (firebaseUser == null) {
        throw Exception("Sign up failed");
      }

      final authApi =
          AuthApiFactory.authApi(appConfig.serverBaseUrl, request.userType);
      final artistOrFan = await authApi.facebookSignup(
          firebaseUser.uid, facebookLoginResult.accessToken.userId);
      if (artistOrFan.isFirst) {
        signupResult.artist = artistOrFan.first;
      } else {
        signupResult.fan = artistOrFan.second;
      }

      return signupResult;
    } on PlatformException catch (e) {
      return AuthResult(request: request)..errorMessage = e.message;
    } on Exception catch (e) {
      return AuthResult(request: request)..errorMessage = e.toString();
    }
  }
}
