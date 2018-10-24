import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/screens/profile/edit_bio_screen.dart';
import 'package:ikonfetemobile/screens/profile/edit_profile_info_screen.dart';
import 'package:ikonfetemobile/screens/profile/profile_screen_bloc.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/utils/twitter_auth.dart';
import 'package:ikonfetemobile/utils/ui_helpers.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileScreen extends StatefulWidget {
  final bool isArtist;
  final String uid;

  ProfileScreen({@required this.isArtist, @required this.uid});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileScreenBloc _bloc;

  bool _initialFacebookEnabled;
  bool _initialTwitterEnabled;
  String _initialBio;
  String _initialCountry;

  String _facebookId;
  String _twitterId;

  String _displayName = "";
  String _email = "";
  bool _facebookEnabled = false;
  bool _twitterEnabled = false;
  String _bio = "";
  String _country = "";
  File _newProfilePicture;
  EditProfileInfoResult _editProfileInfoResult;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final subHeaderTextStyle = TextStyle(
    fontFamily: "SanFranciscoDisplay",
    fontSize: 18.0,
    color: Colors.black87,
  );

  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  HudOverlay hudOverlay;

  @override
  void initState() {
    super.initState();
    final appBloc = BlocProvider.of<ApplicationBloc>(context);

    _displayName = appBloc.initState.currentUser.displayName;
    _email = appBloc.initState.currentUser.email;
    _facebookEnabled = appBloc.initState.isArtist
        ? !StringUtils.isNullOrEmpty(appBloc.initState.artist.facebookId)
        : !StringUtils.isNullOrEmpty(appBloc.initState.fan.facebookId);
    _twitterEnabled = appBloc.initState.isArtist
        ? !StringUtils.isNullOrEmpty(appBloc.initState.artist.twitterId)
        : !StringUtils.isNullOrEmpty(appBloc.initState.fan.twitterId);
    _bio = appBloc.initState.isArtist ? appBloc.initState.artist.bio : "";
    _country =
        appBloc.initState.isArtist ? appBloc.initState.artist.country : "";

    _initialFacebookEnabled = _facebookEnabled;
    _initialTwitterEnabled = _twitterEnabled;
    _initialBio = _bio;
    _initialCountry = _country;

    _facebookId = appBloc.initState.isArtist
        ? appBloc.initState.artist.facebookId
        : appBloc.initState.fan.facebookId;
    _twitterId = appBloc.initState.isArtist
        ? appBloc.initState.artist.twitterId
        : appBloc.initState.fan.twitterId;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = BlocProvider.of<ProfileScreenBloc>(context);
      _subscriptions
          .add(_bloc.facebookAuthResult.listen(_handleFacebookAuthResult));
      _subscriptions
          .add(_bloc.twitterAuthResult.listen(_handleTwitterAuthResult));
    }
  }

  Future<bool> _willPop() async {
    if (_changesMade()) {
      final canPop = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            return AlertDialog(
              title: Text("Save Changes?"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      "There are unsaved changes to your profile. Do you want to discard them?",
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text("YES", style: TextStyle(color: primaryColor)),
                ),
                FlatButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text("NO", style: TextStyle(color: primaryColor)),
                ),
              ],
            );
          });
      return canPop;
    } else {
      return true;
    }
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
              backgroundColor: Colors.black45,
              backgroundImage: !StringUtils.isNullOrEmpty(
                      appBloc.initState.currentUser.photoUrl)
                  ? CachedNetworkImageProvider(
                      appBloc.initState.currentUser.photoUrl)
                  : MemoryImage(kTransparentImage),
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
                    _displayName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black87,
                      fontFamily: "SanFranciscoDisplay",
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    _email,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                      fontFamily: "SanFranciscoDisplay",
                    ),
                  ),
                  widget.isArtist && !StringUtils.isNullOrEmpty(_country)
                      ? Text(
                          _country,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.black54,
                            fontFamily: "SanFranciscoDisplay",
                          ),
                        )
                      : Container(),
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  splashColor: Colors.grey.withOpacity(0.3),
                  child: SizedBox(
                    width: 280.0,
                    height: 70.0,
                    child: Text(
                      _bio,
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
      disabled: !_changesMade(),
      onTap: _saveChanges,
    );
  }

  Widget _buildFacebookConnector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildSocialIcon(ThemifyIcons.facebook, facebookColor),
        SizedBox(width: 20.0),
        Text("Facebook", style: subHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
          value: _facebookEnabled,
          onChanged: (val) {
            setState(() => _facebookEnabled = val);
            // if the user has not yet set up his facebook id
            if (val == true && StringUtils.isNullOrEmpty(_facebookId)) {
              hudOverlay = HudOverlay.showDefault(context);
              _bloc.facebookAuth.add(null);
            }
          },
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
        _buildSocialIcon(ThemifyIcons.twitter, twitterColor),
        SizedBox(width: 20.0),
        Text("Twitter", style: subHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
          value: _twitterEnabled,
          onChanged: (val) {
            setState(() => _twitterEnabled = val);
            // if the user has not yet set up his twitter id
            if (val == true && StringUtils.isNullOrEmpty(_twitterId)) {
              hudOverlay = HudOverlay.showDefault(context);
              _bloc.twitterAuth.add(null);
            }
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  bool _changesMade() {
    return _initialTwitterEnabled != _twitterEnabled ||
        _initialFacebookEnabled != _facebookEnabled ||
        _initialBio != _bio ||
        _initialCountry != _country ||
        _newProfilePicture != null ||
        _editProfileInfoResult != null;
  }

  void _saveChanges() async {

      final data = EditProfileData();
      data.isArtist = widget.isArtist;
      data.uid = widget.uid;
      data.displayName = ;
      data.facebookId = ;
      data.twitterId = ;
      data.bio = ;
      data.countryIsoCode = ;
      data.profilePicture = ;
      data.removeFacebook = ;
      data.removeTwitter = ;

  }

  void _editProfileInfo() async {
    final appBloc = BlocProvider.of<ApplicationBloc>(context);
    final result = await Navigator.of(context).push<EditProfileInfoResult>(
      CupertinoPageRoute(
        builder: (ctx) => EditProfileInfoScreen(
              displayName: _displayName,
              countryIsoCode: widget.isArtist
                  ? appBloc.initState.artist.countryIsoCode
                  : "",
              profileImageUrl: appBloc.initState.currentUser.photoUrl,
            ),
      ),
    );
    if (result != null) {
      setState(() => _editProfileInfoResult = result);
    }
  }

  void _editBio() async {
    String updatedBio = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) {
          return new EditBioScreen(bio: _bio);
        },
      ),
    );
    if (updatedBio != null && updatedBio != _bio) {
      setState(() {
        _bio = updatedBio;
      });
    }
  }

  void _handleFacebookAuthResult(FacebookAuthResult result) {
    hudOverlay?.close();
    if (result.success) {
      _facebookId = result.facebookUID;
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(result.canceled
            ? "Facebook setup cancelled"
            : "Facebook setup falied"),
      ));
      // reset the facebook enabled status
      setState(() => _facebookEnabled = false);
    }
  }

  void _handleTwitterAuthResult(TwitterAuthResult result) {
    hudOverlay?.close();
    if (result.success) {
      _twitterId = result.twitterUID;
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(result.canceled
            ? "Twitter setup cancelled"
            : "Twitter setup falied"),
      ));
      // reset the facebook enabled status
      setState(() => _twitterEnabled = false);
    }
  }

  Widget _buildSocialIcon(IconData iconData, Color iconBGColor) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
        color: iconBGColor,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Icon(iconData, color: Colors.white),
    );
  }
}
