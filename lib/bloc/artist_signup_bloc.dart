import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/user.dart';

class ArtistSignupBloc implements BlocBase {
  String _name;
  String _email;
  String _password;

  // handle names
  StreamController<String> _nameController = StreamController<String>();
  StreamController<String> _emailController = StreamController<String>();
  StreamController<String> _passwordController = StreamController<String>();
  StreamController _actionValidate = StreamController();
  StreamController<MapEntry<bool, String>> _validationResultController =
      StreamController<MapEntry<bool, String>>();
  StreamController _actionSignup = StreamController();
  StreamController<MapEntry<bool, String>> _signupResultController =
      StreamController<MapEntry<bool, String>>();

  StreamSink<String> get name => _nameController.sink;

  StreamSink<String> get email => _emailController.sink;

  StreamSink<String> get password => _passwordController.sink;

  StreamSink get validate => _actionValidate.sink;

  StreamSink<MapEntry<bool, String>> get _validationResult =>
      _validationResultController.sink;

  Stream<MapEntry<bool, String>> get validationResult =>
      _validationResultController.stream;

  StreamSink get signup => _actionSignup.sink;

  StreamSink<MapEntry<bool, String>> get _signupResult =>
      _signupResultController.sink;

  Stream<MapEntry<bool, String>> get signupResult =>
      _signupResultController.stream;

  ArtistSignupBloc() {
    _nameController.stream.listen((val) => _name = val.trim());
    _emailController.stream.listen((val) => _email = val.trim());
    _passwordController.stream.listen((val) => _password = val.trim());
    _actionValidate.stream.listen((_) {
      print("VALIDATING");
      _validateData();
    });
    _actionSignup.stream.listen((_) => _signupUser());
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

  Future _signupUser() async {
    try {
      final firebaseUser = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      final artistsCollection = Firestore.instance.collection("artists");
      final TransactionHandler transaction = (Transaction tx) async {
        final DocumentSnapshot newDoc =
            await tx.get(artistsCollection.document());
        final user = Artist()
          ..uid = firebaseUser.uid
          ..email = firebaseUser.email
          ..name = _name;
        Map data = user.toJson();
        tx.set(newDoc.reference, data);
        return data;
      };

      await Firestore.instance.runTransaction(transaction);
      _signupResult.add(MapEntry(true, null));
    } on PlatformException catch (e) {
      _signupResult.add(MapEntry(false, e.message));
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
