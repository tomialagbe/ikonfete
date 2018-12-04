import 'dart:async';

import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/api/teams.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:meta/meta.dart';

class InboxBloc extends BlocBase {
  final AppConfig appConfig;

  StreamController<String> _loadTeamMembersAction = StreamController<String>();
  StreamController<List<Fan>> _loadTeamMembersResult =
      StreamController.broadcast();

  Stream<List<Fan>> get teamMembers => _loadTeamMembersResult.stream;

  InboxBloc({@required this.appConfig}) {
    _loadTeamMembersAction.stream.listen(_handleLoadTeamMembers);
  }

  @override
  void dispose() {
    _loadTeamMembersAction.close();
    _loadTeamMembersResult.close();
  }

  void loadTeamMembers(String artistUID) =>
      _loadTeamMembersAction.add(artistUID);

  void _handleLoadTeamMembers(String artistUID) async {
    final teamApi = TeamApi(appConfig.serverBaseUrl);
    final artistApi = ArtistApi(appConfig.serverBaseUrl);
    try {
      final team = await artistApi.getArtistTeam(artistUID);
      // get the top 20 team members
      List<Fan> fans = await teamApi.getFansInTeam(team.id, 1, 20);
      _loadTeamMembersResult.add(fans);
    } on ApiException catch (e) {
      _loadTeamMembersResult.addError(e.message);
    }
  }
}
