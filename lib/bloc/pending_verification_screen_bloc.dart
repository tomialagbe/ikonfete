import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:meta/meta.dart';

class ArtistPendingVerificationScreenBloc extends BlocBase {
  final String uid;

  StreamController _loadUserActionController = StreamController();

  StreamController<FirebaseUser> _loadUserResultController =
      StreamController<FirebaseUser>();

  Sink get loadUserAction => _loadUserActionController.sink;

  Stream<FirebaseUser> get loadUserResult => _loadUserResultController.stream;

  ArtistPendingVerificationScreenBloc({@required this.uid}) {
    _loadUserActionController.stream.listen((_) => _handleLoadUserAction());
  }

  @override
  void dispose() {
    _loadUserActionController.close();
    _loadUserResultController.close();
  }

  void _handleLoadUserAction() async {
    final user = await FirebaseAuth.instance.currentUser();
    _loadUserResultController.add(user);
  }
}
