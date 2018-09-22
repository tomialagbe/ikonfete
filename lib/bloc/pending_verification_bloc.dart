import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/collections.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';

class ArtistPendingVerificationBloc extends BlocBase {
  final String uid;

  StreamController _loadUserActionController = StreamController();
  StreamController<Pair<FirebaseUser, Artist>> _loadUserResultController =
      StreamController.broadcast<Pair<FirebaseUser, Artist>>();

  StreamController _logoutActionController = StreamController.broadcast();
  StreamController<bool> _logoutResultController =
      StreamController.broadcast<bool>();

  Sink get logoutAction => _logoutActionController.sink;

  Stream<bool> get logoutResult => _logoutResultController.stream;

  Sink get loadUserAction => _loadUserActionController.sink;

  Stream<Pair<FirebaseUser, Artist>> get loadUserResult =>
      _loadUserResultController.stream;

  ArtistPendingVerificationBloc({@required this.uid}) {
    _loadUserActionController.stream.listen((_) => _handleLoadUserAction());
    _logoutActionController.stream.listen((_) => _handleLogout());
  }

  @override
  void dispose() {
    _loadUserActionController.close();
    _loadUserResultController.close();
    _logoutActionController.close();
    _logoutResultController.close();
  }

  void _handleLoadUserAction() async {
    final user = await FirebaseAuth.instance.currentUser();
    final querySnapshot = await Firestore.instance
        .collection(Collections.artists)
        .where("uid", isEqualTo: user.uid)
        .limit(1)
        .getDocuments();
    final docSnapshot = querySnapshot.documents.first;
    final artist = Artist();
    artist.fromJson(docSnapshot.data);
    _loadUserResultController.add(Pair.from(user, artist));
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _logoutResultController.add(true);
    } on PlatformException {
      _logoutResultController.add(false);
    }
  }
}
