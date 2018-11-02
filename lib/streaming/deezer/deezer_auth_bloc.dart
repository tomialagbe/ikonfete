import 'dart:async';

import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/streaming/deezer/deezer.dart';
import 'package:ikonfetemobile/streaming/deezer/deezer_api.dart';
import 'package:rxdart/rxdart.dart';

class DeezerAuthBloc extends BlocBase {
  DeezerApi _deezerApi;

  ReplaySubject<DeezerUser> _deezerAuthResult = ReplaySubject<DeezerUser>();
  StreamController _deezerAuthAction = StreamController();

  Stream<DeezerUser> get deezerAuthResult => _deezerAuthResult.stream;

  DeezerAuthBloc() {
    _deezerApi = DeezerApi();
  }

  @override
  void dispose() {
    _deezerAuthResult.close();
    _deezerAuthAction.close();
  }

  void authorizeDeezer() async {
    if (!(await _deezerApi.isSessionValid())) {
      bool ok = await _deezerApi.authenticate();
      if (!ok) {
        _deezerAuthResult.addError("Deezer Authentication failed.");
        return;
      }
    }

    final deezerUser = await _deezerApi.getCurrentUser();
    _deezerAuthResult.add(deezerUser);
  }
}
