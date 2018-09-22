import 'dart:async';

import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/types/types.dart';

enum SignupType { artist, fan }

class SignupBloc implements BlocBase {
  final AppConfig appConfig;

  String _name;
  String _email;
  String _password;

  // handle names
  StreamController<String> _nameController = StreamController<String>();
  StreamController<String> _emailController = StreamController<String>();
  StreamController<String> _passwordController = StreamController<String>();
  StreamController<SignupType> _actionSignup = StreamController<SignupType>();
  StreamController<Triple<bool, Artist, String>> _artistSignupResultController =
      StreamController.broadcast<Triple<bool, Artist, String>>();
  StreamController<Triple<bool, Fan, String>> _fanSignupResultController =
      StreamController.broadcast<Triple<bool, Fan, String>>();

  StreamSink<String> get name => _nameController.sink;

  StreamSink<String> get email => _emailController.sink;

  StreamSink<String> get password => _passwordController.sink;

  StreamSink<SignupType> get signup => _actionSignup.sink;

  StreamSink<Triple<bool, Artist, String>> get _artistSignupResult =>
      _artistSignupResultController.sink;

  Stream<Triple<bool, Artist, String>> get artistSignupResult =>
      _artistSignupResultController.stream;

  StreamSink<Triple<bool, Fan, String>> get _fanSignupResult =>
      _fanSignupResultController.sink;

  Stream<Triple<bool, Fan, String>> get fanSignupResult =>
      _fanSignupResultController.stream;

  SignupBloc(this.appConfig) {
    _nameController.stream.listen((val) => _name = val.trim());
    _emailController.stream.listen((val) => _email = val.trim());
    _passwordController.stream.listen((val) => _password = val.trim());
    _actionSignup.stream.listen((type) {
      if (type == SignupType.artist) {
        _signupArtist();
      } else {
        _signupFan();
      }
    });
  }

  @override
  void dispose() {
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    _actionSignup.close();
    _artistSignupResultController.close();
    _fanSignupResultController.close();
  }

  void _signupArtist() async {
    final authApi = AuthApi(appConfig.serverBaseUrl);
    try {
      final artist = await authApi.signupArtist(_name, _email, _password);
      _artistSignupResult.add(Triple.from(true, artist, null));
    } on ApiException catch (e) {
      _artistSignupResult.add(Triple.from(false, null, e.message));
    } on Exception catch (e) {
      _artistSignupResult.add(Triple.from(false, null, e.toString()));
    }
  }

  void _signupFan() async {
    final authApi = AuthApi(appConfig.serverBaseUrl);
    try {
      final fan = await authApi.signupFan(_name, _email, _password);
      _fanSignupResult.add(Triple.from(true, fan, null));
    } on ApiException catch (e) {
      _fanSignupResult.add(Triple.from(false, null, e.message));
    } on Exception catch (e) {
      _fanSignupResult.add(Triple.from(false, null, e.toString()));
    }
  }
}
