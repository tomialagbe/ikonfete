import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/collections.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';

class LoginBloc extends BlocBase {
  String _email;
  String _password;

  final bool isArtist;

  StreamController<String> _emailStreamController = StreamController<String>();
  StreamController<String> _passwordStreamController =
      StreamController<String>();
  StreamController _loginActionController = StreamController();
  StreamController<Triple<FirebaseUser, Artist, String>>
      _artistLoginResultController =
      StreamController.broadcast<Triple<FirebaseUser, Artist, String>>();
  StreamController<Triple<FirebaseUser, Fan, String>>
      _fanLoginResultController =
      StreamController.broadcast<Triple<FirebaseUser, Fan, String>>();

  Sink<String> get email => _emailStreamController.sink;

  Sink<String> get password => _passwordStreamController.sink;

  Sink get loginAction => _loginActionController.sink;

  Stream<Triple<FirebaseUser, Artist, String>> get artistLoginResult =>
      _artistLoginResultController.stream;

  Stream<Triple<FirebaseUser, Fan, String>> get fanLoginResult =>
      _fanLoginResultController.stream;

  LoginBloc({@required this.isArtist}) {
    _emailStreamController.stream.listen((val) => _email = val.trim());
    _passwordStreamController.stream.listen((val) => _password = val.trim());
    _loginActionController.stream
        .listen((_) => isArtist ? _doArtistLogin() : _doFanLogin());
  }

  @override
  void dispose() {
    _emailStreamController.close();
    _passwordStreamController.close();
    _loginActionController.close();
    _artistLoginResultController.close();
    _fanLoginResultController.close();
  }

  void _doArtistLogin() async {
    try {
      final firebaseUser = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      // get the artist
      final querySnapshot = await Firestore.instance
          .collection(Collections.artists)
          .where("uid", isEqualTo: firebaseUser.uid)
          .limit(1)
          .getDocuments();
      if (querySnapshot.documents.isEmpty) {
        throw ApiException("User not found");
      }
      final snapshot = querySnapshot.documents[0];
      final artist = Artist();
      artist.fromJson(snapshot.data);
      _artistLoginResultController.add(Triple.from(firebaseUser, artist, null));
    } on PlatformException catch (e) {
      switch (e.code) {
        case "Error 17020":
          _artistLoginResultController
              .add(Triple.from(null, null, "Network Error."));
          break;
        case "Error 17009":
        default:
          _artistLoginResultController
              .add(Triple.from(null, null, "Invalid email or password."));
          break;
      }
    } on ApiException catch (e) {
      _artistLoginResultController.add(Triple.from(null, null, e.message));
    } on Exception {
      _artistLoginResultController
          .add(Triple.from(null, null, "An unknown error occurred"));
    }
  }

  void _doFanLogin() async {
    try {
      final firebaseUser = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      // get the fan
      final querySnapshot = await Firestore.instance
          .collection(Collections.fans)
          .where("uid", isEqualTo: firebaseUser.uid)
          .limit(1)
          .getDocuments();
      if (querySnapshot.documents.isEmpty) {
        throw ApiException("User not found");
      }
      final snapshot = querySnapshot.documents[0];
      final fan = Fan();
      fan.fromJson(snapshot.data);
      _fanLoginResultController.add(Triple.from(firebaseUser, fan, null));
    } on PlatformException catch (e) {
      switch (e.code) {
        case "Error 17020":
          _fanLoginResultController
              .add(Triple.from(null, null, "Network Error."));
          break;
        case "Error 17009":
        default:
          _fanLoginResultController
              .add(Triple.from(null, null, "Invalid email or password"));
          break;
      }
    } on ApiException catch (e) {
      _fanLoginResultController.add(Triple.from(null, null, e.message));
    } on Exception {
      _fanLoginResultController
          .add(Triple.from(null, null, "An unknown error occurred"));
    }
  }
}
