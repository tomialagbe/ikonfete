import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/main_bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/team.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/screen_utils.dart';
import 'package:ikonfetemobile/screens/fan_team_selection/fan_team_selection_bloc.dart';
import 'package:ikonfetemobile/utils/logout_helper.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/modal.dart';
import 'package:ikonfetemobile/widget/overlays.dart';
import 'package:ikonfetemobile/widget/random_gradient_image.dart';

Widget teamSelectionScreen(BuildContext context, String uid) {
  return BlocProvider<TeamSelectionBloc>(
    bloc: TeamSelectionBloc(appConfig: AppConfig.of(context)),
    child: TeamSelectionScreen(uid: uid),
  );
}

class TeamSelectionScreen extends StatefulWidget {
  final String uid;

  TeamSelectionScreen({@required this.uid});

  @override
  _TeamSelectionScreenState createState() {
    return new _TeamSelectionScreenState();
  }
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final bloc = BlocProvider.of<TeamSelectionBloc>(context);
    bloc.dispatch(LoadFan(widget.uid));
  }

  Future<bool> _canLogout(BuildContext context) async {
    final appBloc = BlocProvider.of<AppBloc>(context);
    bool logout = await canLogout(context);
    if (logout) {
      appBloc.dispatch(Signout());
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<TeamSelectionBloc>(context);
    return WillPopScope(
      onWillPop: () async {
        return _canLogout(context);
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: BlocBuilder<TeamSelectionEvent, TeamSelectionState>(
          bloc: bloc,
          builder: (BuildContext ctx, TeamSelectionState state) {
            if (state.hasError) {
              ScreenUtils.onWidgetDidBuild(() {
                scaffoldKey.currentState
                    .showSnackBar(SnackBar(content: Text(state.errorMessage)));
              });
            } else if (state.teamSelectionResult) {
              // TODO: navigate to home
            } else if (state.selectedTeam != null &&
                state.selectedArtist != null) {
              ScreenUtils.onWidgetDidBuild(() {
                _showArtistModal(state);
              });
            }

            return Container(
              alignment: Alignment.topLeft,
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewInsets.top + 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  OverlayBuilder(
                    child: Container(),
                    showOverlay: state.isLoading,
                    overlayBuilder: (context) => HudOverlay.getOverlay(),
                  ),
                  _buildTitleAndBackButton(context),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 30.0),
                          Text(
                            state.fan == null
                                ? ""
                                : "Hello, ${state.fan.name}!\nJoin your favourite Artist's Team",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              height: 1.4,
                              fontSize: 18.0,
                              color: bodyColor.withOpacity(0.80),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          SearchField(
                            onChanged: (String value) =>
                                bloc.dispatch(SearchQuery(value)),
                          ),
                          SizedBox(height: 20.0),
                          _buildList(context, state),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleAndBackButton(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Select Team",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w100),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Navigator.canPop(context)
                ? IconButton(
                    icon: Icon(CupertinoIcons.back, color: Color(0xFF181D28)),
                    onPressed: () async {
                      bool logout = await _canLogout(context);
                      if (logout) {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context)
                              .pushReplacementNamed(Routes.login);
                        }
                      }
                    },
                  )
                : Container(),
          ],
        )
      ],
    );
  }

  Widget _buildList(BuildContext context, TeamSelectionState state) {
    final bloc = BlocProvider.of<TeamSelectionBloc>(context);
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: state.teams.length,
        itemExtent: 84.0,
        itemBuilder: (BuildContext context, int index) {
          final team = state.teams.isEmpty ? null : state.teams[index];
          if (team == null) {
            return Container();
          }

          return ListTile(
            contentPadding: EdgeInsets.all(0.0),
            leading: StringUtils.isNullOrEmpty(team.teamPictureUrl)
                ? RandomGradientImage()
                : RandomGradientImage(
                    child: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.transparent,
                      backgroundImage:
                          CachedNetworkImageProvider(team.teamPictureUrl),
                    ),
                  ),
            title: Text(
              team.artistName,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              //followers
              StringUtils.abbreviateNumber(team.memberCount, 1),
              style: TextStyle(
                fontSize: 13.0,
                color: Color(0xFF707070),
              ),
            ),
            subtitle: Text(
              team.artistCountry,
              style: TextStyle(
                fontSize: 13.0,
                color: Color(0xFF707070),
              ),
            ),
            enabled: true,
            onTap: () => bloc.dispatch(TeamSelected(team)),
          );
        },
      ),
    );
  }

  void _showArtistModal(TeamSelectionState state) async {
    final bloc = BlocProvider.of<TeamSelectionBloc>(context);
    bool ok = await showModal<bool>(
      context: context,
      contentBackgroundColor: Colors.transparent,
      padding: const EdgeInsets.all(10.0),
      borderRadius: BorderRadius.circular(10.0),
      child: ModalChild<bool>(
        builder: (ctx, mc) {
          return _buildTeamDetailDialogContent(
              ctx, mc, state.selectedTeam, state.selectedArtist);
        },
      ),
    );
    if (ok) {
      // join the artists team and navigate to the team home page
      bloc.dispatch(
          AddFanToTeam(teamId: state.selectedTeam.id, fanUid: state.fan.uid));
    } else {
      bloc.dispatch(ClearSelectedTeam());
    }
  }

  Widget _buildTeamDetailDialogContent(
      BuildContext ctx, ModalChild<bool> mc, Team team, Artist artist) {
    final whiteText = Colors.white.withOpacity(0.9);
    return Container(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(team.teamPictureUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: const Color(0xFFCC181F),
              ),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      team.artistName,
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: whiteText,
                          ),
                    ),
                    SizedBox(height: 10.0),
                    SizedBox(
                      height: 100.0,
                      child: Text(
                        artist.bio,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 7,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(color: whiteText),
                      ),
                    ),
                    Expanded(child: Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => mc.addResult(false),
                        ),
                        Expanded(child: Container()),
                        FlatButton(
                          child: Text("Join Team",
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis),
                          onPressed: () => mc.addResult(true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/*
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/team.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/screens/fan_team_selection/fan_team_selection_bloc.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/utils/logout_helper.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/modal.dart';
import 'package:ikonfetemobile/widget/random_gradient_image.dart';


class FanTeamSelectionScreen extends StatefulWidget {
  /// The fan's uid
  final String uid;
  final String name;

  FanTeamSelectionScreen({
    @required this.uid,
    @required this.name,
  });

  @override
  FanTeamSelectionScreenState createState() => FanTeamSelectionScreenState();
}

class FanTeamSelectionScreenState extends State<FanTeamSelectionScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FanTeamSelectionBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  HudOverlay hudOverlay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<FanTeamSelectionBloc>(context);
      var sub = _bloc.loadArtistForTeamResult.listen((result) {
        _artistForTeamLoaded(true, result.first, result.second, null);
      });
      sub.onError((err) {
        _artistForTeamLoaded(false, null, null, err);
      });
      _subscriptions.add(sub);

      var fsub = _bloc.addFanToTeamResult.listen((result) {
        _handleAddFanToTeamResult(result, null);
      });
      fsub.onError((err) {
        _handleAddFanToTeamResult(false, err);
      });
      _subscriptions.add(fsub);
    }
    _bloc.searchArtistTeam.add("");
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    super.dispose();
  }

  Future<bool> _canLogout() async {
    bool logout = await canLogout(context);
    if (logout) {
      return await BlocProvider.of<ApplicationBloc>(context).doLogout();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _canLogout,
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Container(
          alignment: Alignment.topLeft,
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewInsets.top + 40.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTitleAndBackButton(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 30.0),
                      Text(
                        "Hello, ${widget.name}!\nJoin your favourite Artist's Team",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          height: 1.4,
                          fontSize: 18.0,
                          color: bodyColor.withOpacity(0.80),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      SearchField(
                        onChanged: (String value) {
                          _bloc.searchArtistTeam.add(value);
                        },
                      ),
                      SizedBox(height: 20.0),
                      _buildList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Expanded(
      child: StreamBuilder<List<Team>>(
        stream: _bloc.searchArtistTeamResult,
        initialData: <Team>[],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data.length,
              itemExtent: 84.0,
              itemBuilder: (BuildContext context, int index) {
                final team =
                    snapshot.data.isEmpty ? null : snapshot.data[index];
                if (team == null) {
                  return Container();
                }

                return ListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  leading: StringUtils.isNullOrEmpty(team.teamPictureUrl)
                      ? RandomGradientImage()
                      : RandomGradientImage(
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.transparent,
                            backgroundImage:
                                CachedNetworkImageProvider(team.teamPictureUrl),
                          ),
                        ),
                  title: Text(
                    team.artistName,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    //followers
                    StringUtils.abbreviateNumber(team.memberCount, 1),
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF707070),
                    ),
                  ),
                  subtitle: Text(
                    team.artistCountry,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Color(0xFF707070),
                    ),
                  ),
                  enabled: true,
                  onTap: () => _teamSelected(team),
                );
              },
            );
          } else {
            return Container(
              child: Center(
                child: Text("No artists available"),
              ),
            );
          }
        },
      ),
    );
  }

  void _artistForTeamLoaded(
      bool success, Team team, Artist artist, String error) async {
    if (!success) {
      hudOverlay?.close();
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (c) {
            return AlertDialog(
              title: Text("Error"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      error,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(c);
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            );
          });
    } else {
      // load the team image first
//      final bytes = await _loadImageBytes(team.teamPictureUrl);
      hudOverlay?.close();
      // show team details
      bool ok = await showModal<bool>(
        context: context,
        contentBackgroundColor: Colors.transparent,
        padding: const EdgeInsets.all(10.0),
        borderRadius: BorderRadius.circular(10.0),
        child: ModalChild<bool>(
          builder: (ctx, mc) {
            return _buildTeamDetailDialogContent(
                ctx, mc, team, artist, team.teamPictureUrl);
          },
        ),
      );
      if (ok) {
        // join the artists team and navigate to the team home page
        hudOverlay = HudOverlay.showDefault(context);
        _bloc.addFanToTeam.add(Pair.from(team.id, widget.uid));
      }
    }
  }

  void _handleAddFanToTeamResult(bool result, String error) {
    hudOverlay?.close();
    if (!result) {
      final err = error ?? "An unknown error occurred";
      scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(err)));
    } else {
      // fan successfully added to team
      router.navigateTo(context, RouteNames.fanHome,
          replace: true, transition: TransitionType.inFromRight);
    }
  }

  Widget _buildTeamDetailDialogContent(BuildContext ctx, ModalChild<bool> mc,
      Team team, Artist artist, String pictureUrl) {
    final whiteText = Colors.white.withOpacity(0.9);
    return Container(
      color: Colors.transparent,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(pictureUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                color: const Color(0xFFCC181F),
              ),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      team.artistName,
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500,
                            color: whiteText,
                          ),
                    ),
                    SizedBox(height: 10.0),
                    SizedBox(
                      height: 100.0,
                      child: Text(
                        artist.bio,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 7,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(color: whiteText),
                      ),
                    ),
                    Expanded(child: Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () => mc.addResult(false),
                        ),
                        Expanded(child: Container()),
                        FlatButton(
                          child: Text("Join Team",
                              style: TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis),
                          onPressed: () => mc.addResult(true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

//  Future<Uint8List> _loadImageBytes(String url) async {
//    try {
//      final response = await http.get(url);
//      if (response.statusCode == 200) {
//        return response.bodyBytes;
//      }
//      return null;
//    } on Exception catch (e) {
//      // image failed to load
//      // TODO: handle better
//      return null;
//    }
//  }
}
*/
