import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/collections.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/auth_type.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:meta/meta.dart';

class SignupResult {
  Artist _artist;
  Fan _fan;
  String _errorMessage;
  SignupActionRequest request;

  SignupResult({@required this.request});

  set errorMessage(String val) {
    _errorMessage = val;
    _artist = null;
    _fan = null;
  }

  set fan(Fan val) {
    assert(val != null);
    _fan = val;
    _artist = null;
  }

  set artist(Artist val) {
    assert(val != null);
    _artist = val;
    _fan = null;
  }

  bool get success => _artist != null || _fan != null;

  String get errorMessage => _errorMessage;

  Artist get artist => _artist;

  Fan get fan => _fan;

  bool get isArtist => _artist != null;

  bool get isFan => _fan != null;
}

class SignupActionRequest {
  AuthUserType userType;
  AuthProvider provider;

  SignupActionRequest({
    @required this.userType,
    @required this.provider,
  });

  bool get isArtist => userType == AuthUserType.artist;

  bool get isFan => userType == AuthUserType.fan;

  bool get isEmailProvider => provider == AuthProvider.email;

  bool get isFacebookProvider => provider == AuthProvider.facebook;
}

class SignupBloc implements BlocBase {
  final AppConfig appConfig;

  String _name;
  String _email;
  String _password;

  // handle names
  StreamController<String> _nameController = StreamController<String>();
  StreamController<String> _emailController = StreamController<String>();
  StreamController<String> _passwordController = StreamController<String>();
  StreamController<SignupActionRequest> _actionSignup =
      StreamController<SignupActionRequest>();

  StreamController<SignupResult> _signupResultController =
      StreamController.broadcast<SignupResult>();

  StreamSink<String> get name => _nameController.sink;

  StreamSink<String> get email => _emailController.sink;

  StreamSink<String> get password => _passwordController.sink;

  StreamSink<SignupActionRequest> get signup => _actionSignup.sink;

  Sink<SignupResult> get _signupResult => _signupResultController.sink;

  Stream<SignupResult> get signupResult => _signupResultController.stream;

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

  void _handleSignupRequest(SignupActionRequest request) async {
    SignupResult result;
    if (request.isEmailProvider) {
      result = await _emailSignup(request);
    } else {
      result = await _facebookSignup(request);
    }
    _signupResult.add(result);
  }

  Future<SignupResult> _emailSignup(SignupActionRequest request) async {
    final authApi =
        AuthApiFactory.authApi(appConfig.serverBaseUrl, request.userType);
    final signupResult = SignupResult(request: request);
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

  Future<SignupResult> _facebookSignup(SignupActionRequest request) async {
    final _createArtist = (String docId, FirebaseUser firebaseUser,
        FacebookLoginResult facebookLoginResult) {
      return Artist()
        ..id = docId
        ..uid = firebaseUser.uid
        ..facebookId = facebookLoginResult.accessToken.userId
        ..twitterId = ""
        ..username = ""
        ..name = firebaseUser.displayName;
    };

    final _createFan = (String docId, FirebaseUser firebaseUser,
        FacebookLoginResult facebookLoginResult) {
      return Fan()
        ..id = docId
        ..uid = firebaseUser.uid
        ..facebookId = facebookLoginResult.accessToken.userId
        ..twitterId = ""
        ..username = ""
        ..name = firebaseUser.displayName;
    };

    try {
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
      final firebaseUser = await FirebaseAuth.instance
          .signInWithFacebook(accessToken: result.accessToken.token);

      final coll = Firestore.instance.collection(
          request.isArtist ? Collections.artists : Collections.fans);
      // check if user has signed up with facebook before
      final querySnapshot = await coll
          .where("facebookId", isEqualTo: result.accessToken.userId)
          .getDocuments();
      bool isSignedUp = querySnapshot.documents.isNotEmpty;
      final signupResult = SignupResult(request: request);
      if (!isSignedUp) {
        final doc = coll.document();
        final user = request.isArtist
            ? _createArtist(doc.documentID, firebaseUser, result)
            : _createFan(doc.documentID, firebaseUser, result);
        if (request.isArtist) {
          signupResult.artist = user;
        } else {
          signupResult.fan = user;
        }
        return signupResult;
      } else {
        signupResult.errorMessage = "This account already exists";
        return signupResult;
      }
    } on PlatformException catch (e) {
      return SignupResult(request: request)..errorMessage = e.message;
    } on Exception catch (e) {
      return SignupResult(request: request)..errorMessage = e.toString();
    }
  }
}
