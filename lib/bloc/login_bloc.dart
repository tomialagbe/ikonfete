import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
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
      StreamController<Triple<FirebaseUser, Artist, String>>();

  Sink<String> get email => _emailStreamController.sink;

  Sink<String> get password => _passwordStreamController.sink;

  Sink get loginAction => _loginActionController.sink;

  Stream<Triple<FirebaseUser, Artist, String>> get artistLoginResult =>
      _artistLoginResultController.stream;

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
  }

  void _doArtistLogin() async {
    try {
      final firebaseUser = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _password);
      // get the artist
      final querySnapshot = await Firestore.instance
          .collection("artists")
          .where("uid", isEqualTo: firebaseUser.uid)
          .limit(1)
          .getDocuments();
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
//        default:
//          _loginResultController.add(Pair.from(
//              null, "An unknown error occurred. Please try again later."));
//          break;
      }
    }
  }

  void _doFanLogin() {}
}
