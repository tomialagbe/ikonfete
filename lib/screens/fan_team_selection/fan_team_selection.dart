import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/screens/fan_team_selection/fan_team_selection_bloc.dart';
import 'package:ikonfetemobile/screens/logout_helper.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';

class FanTeamSelectionScreen extends StatefulWidget {
  /// The fan's uid
  final String uid;

  FanTeamSelectionScreen({this.uid});

  @override
  FanTeamSelectionScreenState createState() => FanTeamSelectionScreenState();
}

class FanTeamSelectionScreenState extends State<FanTeamSelectionScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FanTeamSelectionBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<FanTeamSelectionBloc>(context);
    }
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
                        "Hello, Jane!\nJoin your favourite Artist",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          height: 1.4,
                          fontSize: 18.0,
                          color: bodyColor.withOpacity(0.80),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      SearchField(
                        onChanged: (String value) {},
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
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 10,
        itemExtent: 84.0,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            contentPadding: EdgeInsets.all(0.0),
            leading: Container(
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
            ),
            title: Text(
              'Artist Name',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              "500k",
              style: TextStyle(
                fontSize: 13.0,
                color: Color(0xFF707070),
              ),
            ),
            //followers
            subtitle: Text(
              'Country',
              style: TextStyle(
                fontSize: 13.0,
                color: Color(0xFF707070),
              ),
            ),
            enabled: true,
            onTap: () {
              /* react to the tile being tapped */
            },
          );
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
}
