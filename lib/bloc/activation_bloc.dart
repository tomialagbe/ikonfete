import 'dart:async';

import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:rxdart/rxdart.dart';

class ActivationBloc implements BlocBase {
  final AppConfig appConfig;
  final bool isArtist;
  final String uid;

  String _code;

  StreamController _actionController = StreamController();
  StreamController<String> _activationCodeController =
      StreamController<String>();

  StreamSink<String> get activationCode => _activationCodeController.sink;

  StreamSink get activate => _actionController.sink;

  PublishSubject<Pair<bool, String>> _resultController =
      PublishSubject<Pair<bool, String>>();

  Stream<Pair<bool, String>> get result => _resultController.stream;

  Sink<Pair<bool, String>> get _result => _resultController.sink;

  ActivationBloc(
    this.appConfig, {
    this.isArtist,
    this.uid,
  }) {
    _activationCodeController.stream.listen((code) => this._code = code);
    _actionController.stream.listen((_) => _handleActivationCode());
  }

  @override
  void dispose() {
    _actionController.close();
    _activationCodeController.close();
    _resultController.close();
  }

  void _handleActivationCode() async {
    final authApi = AuthApi(appConfig.serverBaseUrl);

    try {
      bool ok = await authApi.activateUser(uid, _code);
      _result.add(Pair.from(ok, null));
    } on ApiException catch (e) {
      _result.add(Pair.from(false, e.message));
    } on Exception catch (e) {
      _result.add(Pair.from(false, e.toString()));
    }
  }
}
