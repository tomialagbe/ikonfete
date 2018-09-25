import 'dart:async';

import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/auth.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/auth_type.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';

class InactiveUserScreenBloc extends BlocBase {
  final AppConfig appConfig;
  final bool isArtist;

  StreamController<String> _resendActivationActionController =
      StreamController<String>();
  StreamController<Pair<bool, String>> _resendActivationResultController =
      StreamController<Pair<bool, String>>();

  Sink get resendActivationAction => _resendActivationActionController.sink;

  Stream<Pair<bool, String>> get resendActivationResult =>
      _resendActivationResultController.stream;

  InactiveUserScreenBloc({
    @required this.appConfig,
    @required this.isArtist,
  }) {
    _resendActivationActionController.stream
        .listen(_handleResendActivationAction);
  }

  @override
  void dispose() {
    _resendActivationActionController.close();
    _resendActivationResultController.close();
  }

  void _handleResendActivationAction(String uid) async {
    try {
      final authApi = AuthApiFactory.authApi(appConfig.serverBaseUrl,
          isArtist ? AuthUserType.artist : AuthUserType.fan);
      final success = await authApi.resendActivationCode(uid);
      _resendActivationResultController.add(Pair.from(success, null));
    } on ApiException catch (e) {
      _resendActivationResultController.add(Pair.from(false, e.message));
    } on Exception catch (e) {
      _resendActivationResultController.add(Pair.from(false, e.toString()));
    }
  }
}
