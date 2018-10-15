import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/utils/ui_helpers.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class ProfileScreen extends StatefulWidget {
  final bool isArtist;
  final String uid;

  ProfileScreen({@required this.isArtist, @required this.uid});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final subHeaderTextStyle = TextStyle(
    fontFamily: "SanFranciscoDisplay",
    fontSize: 18.0,
    color: Colors.black87,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<bool> _willPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      _buildProfileInfo(),
    ];
    if (widget.isArtist) {
      children.add(_buildBio());
    }
    children.add(_buildSocialProfileConnector());
    children.add(Expanded(child: Container()));
    children.add(_buildSaveButton());

    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
        appBar: UiHelpers.appBar(
          title: "Profile",
          backgroundColor: Colors.white,
          leading: new IconButton(
            icon: new Icon(LineAwesomeIcons.times, color: Colors.black54),
            onPressed: () async {
              if (await _willPop()) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: Container(
          alignment: Alignment.topLeft,
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    final appBloc = BlocProvider.of<ApplicationBloc>(context);
    final editProfileTapHandler = TapGestureRecognizer();
    editProfileTapHandler.onTap = _editProfileInfo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: SizedBox(
        height: 90.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 45.0,
              foregroundColor: Colors.black45,
              backgroundImage: CachedNetworkImageProvider(
                  appBloc.initState.profilePictureUrl),
            ),
            SizedBox(width: 20.0),
            SizedBox(
              width: 170.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    appBloc.initState.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black87,
                      fontFamily: "SanFranciscoDisplay",
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    appBloc.initState.email,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                      fontFamily: "SanFranciscoDisplay",
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Container()),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    text: "Edit",
                    recognizer: editProfileTapHandler,
                    style: TextStyle(
                      color: primaryColor,
                      fontFamily: "SanFranciscoDisplay",
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBio() {
    final editBioTapHandler = TapGestureRecognizer();
    editBioTapHandler.onTap = _editBio;

    return Container(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Bio",
            style: subHeaderTextStyle,
          ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                width: 280.0,
                height: 70.0,
                child: Text(
                  "dbajd dada dankdad dakbdajda dank bdaj addabj daknd dad daknd"
                      " a adbaj qebiqdkaln cdadkb qqrfajeqkb cqenocq "
                      "dbajd dada dankdad dakbdajda dank bdaj addabj daknd dad daknd"
                      " a adbaj qebiqdkaln cdadkb qqrfajeqkb cqenocq ",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 4,
                  style: TextStyle(
                    fontFamily: "SanFranciscoDisplay",
                    fontSize: 14.0,
                    color: Colors.black54,
                  ),
                ),
              ),
              Expanded(child: Container()),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: "Edit",
                      recognizer: editBioTapHandler,
                      style: TextStyle(
                        color: primaryColor,
                        fontFamily: "SanFranciscoDisplay",
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSocialProfileConnector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Connected Social Profiles",
          style: subHeaderTextStyle,
        ),
        SizedBox(height: 30.0),
        _buildFacebookConnector(),
        SizedBox(height: 20.0),
        _buildTwitterConnector(),
      ],
    );
  }

  Widget _buildSaveButton() {
    return PrimaryButton(
      width: MediaQuery.of(context).size.width - 40.0,
      height: 50.0,
      defaultColor: primaryButtonColor,
      activeColor: primaryButtonActiveColor,
      text: "SAVE SETTINGS",
      disabled: true,
      onTap: () {},
    );
  }

  Widget _buildFacebookConnector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: facebookColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Icon(ThemifyIcons.facebook, color: Colors.white),
        ),
        SizedBox(width: 20.0),
        Text("Facebook", style: subHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
          value: true,
          onChanged: (val) {},
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildTwitterConnector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: twitterColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Icon(ThemifyIcons.twitter, color: Colors.white),
        ),
        SizedBox(width: 20.0),
        Text("Twitter", style: subHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
          value: true,
          onChanged: (val) {},
          activeColor: primaryColor,
        ),
      ],
    );
  }

  void _editProfileInfo() {}

  void _editBio() {}
}
