import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';

class ApplicationBloc implements BlocBase {
  StreamController _logoutActionController = StreamController.broadcast();
  StreamController<bool> _logoutResultController =
      StreamController.broadcast<bool>();

  Sink get logoutAction => _logoutActionController.sink;

  Stream<bool> get logoutResult => _logoutResultController.stream;

  @override
  void dispose() {
    _logoutActionController.close();
    _logoutResultController.close();
  }

  ApplicationBloc() {
    _logoutActionController.stream.listen((_) => _handleLogout());
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      _logoutResultController.add(true);
    } on PlatformException {
      _logoutResultController.add(false);
    }
  }

  Future<bool> doLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on PlatformException {
      return false;
    }
  }
}
