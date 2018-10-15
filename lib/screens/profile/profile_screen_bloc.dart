import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:meta/meta.dart';

class ProfileScreenBloc extends BlocBase {
  final AppConfig appConfig;
  final bool isArtist;

  ProfileScreenBloc({
    @required this.appConfig,
    @required this.isArtist,
  });

  @override
  void dispose() {}
}
