import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/types/types.dart';

class ArtistSignupBloc implements BlocBase {
  final AppConfig appConfig;

  String _name;
  String _email;
  String _password;

  // handle names
  StreamController<String> _nameController = StreamController<String>();
  StreamController<String> _emailController = StreamController<String>();
  StreamController<String> _passwordController = StreamController<String>();
  StreamController _actionValidate = StreamController();
  StreamController<MapEntry<bool, String>> _validationResultController =
      StreamController.broadcast<MapEntry<bool, String>>();
  StreamController _actionSignup = StreamController();
  StreamController<Triple<bool, Artist, String>> _signupResultController =
      StreamController.broadcast<Triple<bool, Artist, String>>();

  StreamSink<String> get name => _nameController.sink;

  StreamSink<String> get email => _emailController.sink;

  StreamSink<String> get password => _passwordController.sink;

  StreamSink get validate => _actionValidate.sink;

  StreamSink<MapEntry<bool, String>> get _validationResult =>
      _validationResultController.sink;

  Stream<MapEntry<bool, String>> get validationResult =>
      _validationResultController.stream;

  StreamSink get signup => _actionSignup.sink;

  StreamSink<Triple<bool, Artist, String>> get _signupResult =>
      _signupResultController.sink;

  Stream<Triple<bool, Artist, String>> get signupResult =>
      _signupResultController.stream;

  ArtistSignupBloc(this.appConfig) {
    _nameController.stream.listen((val) => _name = val.trim());
    _emailController.stream.listen((val) => _email = val.trim());
    _passwordController.stream.listen((val) => _password = val.trim());
    _actionValidate.stream.listen((_) {
      print("VALIDATING");
      _validateData();
    });
    _actionSignup.stream.listen((_) => _signupArtist());
  }

  @override
  void dispose() {
    _nameController.close();
    _emailController.close();
    _passwordController.close();
    _actionValidate.close();
    _validationResultController.close();
    _actionSignup.close();
    _signupResultController.close();
  }

  Future _validateData() async {
    if (await _emailExists(_email)) {
      _validationResult.add(MapEntry<bool, String>(
          false, "A user with this email already exists."));
    } else {
      _validationResult.add(MapEntry<bool, String>(true, null));
    }
  }

  void _signupArtist() async {
    final authApi = AuthApi(appConfig.serverBaseUrl);
    try {
      final artist = await authApi.signupArtist(_name, _email, _password);
      _signupResult.add(Triple.from(true, artist, null));
    } on ApiException catch (e) {
      _signupResult.add(Triple.from(false, null, e.message));
    } on Exception catch (e) {
      _signupResult.add(Triple.from(false, null, e.toString()));
    }
  }

  Future<bool> _emailExists(String email) async {
    final query = await Firestore.instance
        .collection("users")
        .where("email", isEqualTo: _email)
        .getDocuments();
    return query.documents.isNotEmpty;
  }
}
