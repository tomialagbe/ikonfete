import 'dart:async';

import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/api/teams.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/model/team.dart';
import 'package:meta/meta.dart';

class ArtistData {
  Artist artist;
  Team artistTeam;
}

class IkonScreenBloc extends BlocBase {
  final AppConfig appConfig;

  /// StreamController that handles artist UIDs
  StreamController<Fan> _loadArtistForFanActionController =
      StreamController<Fan>();

  /// StreamController that handles load artist results
  StreamController<ArtistData> _loadArtistResultController =
      StreamController.broadcast();

  Sink get loadArtistForFan => _loadArtistForFanActionController.sink;

  Stream<ArtistData> get loadArtistResult => _loadArtistResultController.stream;

  IkonScreenBloc({
    @required this.appConfig,
  }) {
    _loadArtistForFanActionController.stream.listen(_loadArtistForFan);
  }

  @override
  void dispose() {
    _loadArtistForFanActionController.close();
    _loadArtistResultController.close();
  }

  void _loadArtistForFan(Fan fan) async {
    final teamApi = TeamApi(appConfig.serverBaseUrl);
    final artistApi = ArtistApi(appConfig.serverBaseUrl);

    try {
      // get the team this fan belongs to
      final team = await teamApi.getTeamByID(fan.currentTeamId);
      if (team == null) {
        _loadArtistResultController.addError("Team not found");
        return;
      }

      final artist = await artistApi.findByUID(team.artistUid);
      if (artist == null) {
        _loadArtistResultController.addError("Artist not found");
        return;
      }
      final artistData = ArtistData()
        ..artist = artist
        ..artistTeam = team;
      _loadArtistResultController.add(artistData);
    } on ApiException catch (e) {
      _loadArtistResultController.addError(e.message);
    }
  }
}
