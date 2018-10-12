import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/team.dart';
import 'package:ikonfetemobile/screens/fan_team_selection/fan_team_selection_bloc.dart';
import 'package:ikonfetemobile/screens/logout_helper.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/modal.dart';
import 'package:transparent_image/transparent_image.dart';

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
      final sub = _bloc.loadArtistForTeamResult.listen((result) {
        _artistForTeamLoaded(true, result.first, result.second, null);
      });
      sub.onError((err) {
        _artistForTeamLoaded(false, null, null, err);
      });
      _subscriptions.add(sub);
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
//                trailing: Text(
//                  //followers
//                  team.teamSize.toString(), //500k
//                  style: TextStyle(
//                    fontSize: 13.0,
//                    color: Color(0xFF707070),
//                  ),
//                ),
//                subtitle: Text(
//                  '',// Country
//                  style: TextStyle(
//                    fontSize: 13.0,
//                    color: Color(0xFF707070),
//                  ),
//                ),
                  enabled: true,
                  onTap: () => _teamSelected(team),
                );
              },
            );
          } else {
            Container(
              child: Center(
                child: Text("No artists available"),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTitleAndBackButton() {
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
            IconButton(
              icon: Icon(CupertinoIcons.back, color: Color(0xFF181D28)),
              onPressed: _canLogout,
            ),
          ],
        )
      ],
    );
  }

  void _teamSelected(Team team) {
    hudOverlay = HudOverlay.show(
        context, HudOverlay.dotsLoadingIndicator(), HudOverlay.defaultColor());
    _bloc.loadArtistForTeam.add(team);
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
      final bytes = await _loadImageBytes(team.teamPictureUrl);
      hudOverlay?.close();
      // show team details
      bool ok = await showModal<bool>(
        context: context,
        contentBackgroundColor: Colors.white,
        padding: const EdgeInsets.all(0.0),
        borderRadius: BorderRadius.circular(10.0),
        child: ModalChild<bool>(
          builder: (ctx, mc) {
            return _buildTeamDetailDialogContent(ctx, mc, team, artist, bytes);
          },
        ),
      );
      print("OK: $ok");
    }
  }

  Widget _buildTeamDetailDialogContent(BuildContext ctx, ModalChild<bool> mc,
      Team team, Artist artist, Uint8List teamPictureBytes) {
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
                  image: MemoryImage(teamPictureBytes ?? kTransparentImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: Center(
                  child: FlatButton(
                child: Text("Cancel"),
                onPressed: () => mc.addResult(false),
              )),
            ),
          )
        ],
      ),
    );
  }

  Future<Uint8List> _loadImageBytes(String url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return response.bodyBytes;
    }
    return null;
  }
}

class RandomGradientImage extends StatelessWidget {
  final Widget child;

  RandomGradientImage({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64.0,
      width: 64.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(32.0),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.fromARGB(
              200,
              Random().nextInt(255),
              Random().nextInt(255),
              Random().nextInt(255),
            ).withOpacity(.8),
            Colors.grey.withOpacity(.8),
          ],
        ),
      ),
      child: child ?? Container(),
    );
  }
}
