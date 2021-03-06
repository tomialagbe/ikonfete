import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/main_bloc.dart';
import 'package:ikonfetemobile/screen_utils.dart';
import 'package:ikonfetemobile/screens/profile/edit_bio_screen.dart';
import 'package:ikonfetemobile/screens/profile/edit_profile_info_screen.dart';
import 'package:ikonfetemobile/screens/profile/profile_screen_bloc.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:ikonfetemobile/widget/overlays.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';
import 'package:transparent_image/transparent_image.dart';

final Screen profileScreen = Screen(
  title: "Profile",
  contentBuilder: (ctx) {
    final appBloc = BlocProvider.of<AppBloc>(ctx);
    return BlocBuilder<AppEvent, AppState>(
      bloc: appBloc,
      builder: (BuildContext appCtx, AppState appState) {
        final profileScreenBloc =
            ProfileScreenBloc(appConfig: AppConfig.of(ctx));
        return ProfileScreen(appState: appState, bloc: profileScreenBloc);
//        return BlocProvider<ProfileScreenBloc>(
//          bloc: ProfileScreenBloc(appConfig: AppConfig.of(ctx)),
//          child: ProfileScreen(appState: appState),
//        );
      },
    );
  },
);

class ProfileScreen extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final subHeaderTextStyle = TextStyle(
    fontFamily: "SanFranciscoDisplay",
    fontSize: 18.0,
    color: Colors.black87,
  );

  final AppState appState;
  final ProfileScreenBloc bloc;

  ProfileScreen({@required this.appState, @required this.bloc}) {
    bloc.dispatch(InitProfile(this.appState));
  }

  Future<bool> _willPop(BuildContext context) async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return _willPop(context);
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: BlocBuilder<ProfileScreenEvent, ProfileScreenState>(
          bloc: bloc,
          builder: (BuildContext bldrContext, ProfileScreenState state) {
            if (state.hasError) {
              ScreenUtils.onWidgetDidBuild(() {
                scaffoldKey.currentState
                    .showSnackBar(SnackBar(content: Text(state.errorMessage)));
              });
            }

            final children = <Widget>[
              OverlayBuilder(
                child: Container(),
                showOverlay: state.isLoading,
                overlayBuilder: (context) => HudOverlay.getOverlay(),
              ),
              _buildProfileInfo(context, state),
              _buildEmail(state),
            ];
            if (appState.isArtist) {
              children.add(_buildBio(context, state));
            }
            children.add(_buildSocialProfileConnector(state));
            children.add(Expanded(child: Container()));
            children.add(_buildSaveButton(context, state));

            return Container(
              alignment: Alignment.topLeft,
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, ProfileScreenState state) {
    final editProfileTapHandler = TapGestureRecognizer();
    editProfileTapHandler.onTap = () {
      _editProfileInfo(context, state);
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
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
              backgroundImage: state.newProfilePicture != null
                  ? FileImage(state.newProfilePicture)
                  : StringUtils.isNullOrEmpty(state.profilePictureUrl)
                      ? MemoryImage(kTransparentImage)
                      : CachedNetworkImageProvider(state.profilePictureUrl),
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
                    "${StringUtils.isNullOrEmpty(state.newDisplayName) ? state.displayName : state.newDisplayName}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black87,
                      fontFamily: "SanFranciscoDisplay",
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    "@${state.username}",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                      fontFamily: "SanFranciscoDisplay",
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    StringUtils.isNullOrEmpty(state.newCountry)
                        ? state.country
                        : state.newCountry ?? "",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black45,
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

  void _editProfileInfo(BuildContext context, ProfileScreenState state) async {
    final result = await Navigator.of(context).push<EditProfileInfoResult>(
      CupertinoPageRoute(
        builder: (ctx) => EditProfileInfoScreen(
              bloc: bloc,
            ),
      ),
    );
    if (result != null) {
      bloc.dispatch(ProfileInfoChange(
        profilePicture: result.profilePicture,
        country: result.country,
        countryIsoCode: result.countryIsoCode,
        displayName: result.displayName,
      ));
    }
  }

  Widget _buildEmail(ProfileScreenState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Email",
          style: subHeaderTextStyle,
        ),
        SizedBox(height: 10.0),
        Text(
          state.email,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black54,
            fontFamily: "SanFranciscoDisplay",
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }

  Widget _buildBio(BuildContext context, ProfileScreenState state) {
    final editBioTapHandler = TapGestureRecognizer();
    editBioTapHandler.onTap = () {
      _editBio(context, state);
    };

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
                      StringUtils.isNullOrEmpty(state.newBio)
                          ? state.bio
                          : state.newBio,
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

  void _editBio(BuildContext context, ProfileScreenState state) async {
    String updatedBio = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) {
          return EditBioScreen(bio: state.bio);
        },
      ),
    );
    bloc.dispatch(BioUpdated(updatedBio));
  }

  Widget _buildSocialProfileConnector(ProfileScreenState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Connected Social Profiles",
          style: subHeaderTextStyle,
        ),
        SizedBox(height: 30.0),
        _buildFacebookConnector(state),
        SizedBox(height: 20.0),
        _buildTwitterConnector(state),
      ],
    );
  }

  Widget _buildFacebookConnector(ProfileScreenState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildSocialIcon(ThemifyIcons.facebook, facebookColor),
        SizedBox(width: 20.0),
        Text("Facebook", style: subHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
          value: state.facebookEnabled,
          onChanged: (val) {
            bloc.dispatch(FacebookEnabled(val));
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildTwitterConnector(ProfileScreenState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _buildSocialIcon(ThemifyIcons.twitter, twitterColor),
        SizedBox(width: 20.0),
        Text("Twitter", style: subHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
          value: state.twitterEnabled,
          onChanged: (val) {
            bloc.dispatch(TwitterEnabled(val));
          },
          activeColor: primaryColor,
        ),
      ],
    );
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

  Widget _buildSaveButton(BuildContext context, ProfileScreenState state) {
    return PrimaryButton(
      width: MediaQuery.of(context).size.width - 40.0,
      height: 50.0,
      defaultColor: primaryButtonColor,
      activeColor: primaryButtonActiveColor,
      text: "SAVE SETTINGS",
      disabled: !_changesMade(state),
      onTap: () {
        _saveChanges(state);
      },
    );
  }

  bool _changesMade(ProfileScreenState state) {
    return state.displayName != state.newDisplayName ||
        state.newProfilePicture != null ||
        state.countryIsoCode != state.newCountryIsoCode ||
        state.country != state.newCountry ||
        state.bio != state.newBio ||
        state.facebookId != state.newFacebookId ||
        state.twitterId != state.newTwitterId;
  }

  void _saveChanges(ProfileScreenState state) async {
    final data = EditProfileData();
    data.isArtist = appState.isArtist;
    data.uid = appState.uid;
    data.displayName = state.newDisplayName.trim();
    data.facebookId = state.newFacebookId;
    data.twitterId = state.newTwitterId;
    data.bio = state.newBio.trim();
    data.countryIsoCode = state.newCountryIsoCode;
    data.profilePicture = state.newProfilePicture;
    data.oldProfilePictureUrl = state.profilePictureUrl;
    data.removeFacebook = !StringUtils.isNullOrEmpty(state.facebookId) &&
        StringUtils.isNullOrEmpty(state.newFacebookId) &&
        !state.facebookEnabled;
    data.removeTwitter = !StringUtils.isNullOrEmpty(state.twitterId) &&
        StringUtils.isNullOrEmpty(state.newTwitterId) &&
        !state.twitterEnabled;
    bloc.dispatch(EditProfile(data));
  }
}

/*
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
  String _username = "";
  String _email = "";
  bool _facebookEnabled = false;
  bool _twitterEnabled = false;
  String _bio = "";
  String _country = "";
  String _countryIsoCode = "";
  File _newProfilePicture;
  EditProfileInfoResult _editProfileInfoResult;
  String _oldProfilePictureUrl;
  String _profilePictureUrl;

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

    _displayName = appBloc.initState.isArtist
        ? appBloc.initState.artist.name
        : appBloc.initState.fan.name;
    _username = appBloc.initState.isArtist
        ? appBloc.initState.artist.username
        : appBloc.initState.fan.username;
    _email = appBloc.initState.currentUser.email;
    _facebookEnabled = appBloc.initState.isArtist
        ? !StringUtils.isNullOrEmpty(appBloc.initState.artist.facebookId)
        : !StringUtils.isNullOrEmpty(appBloc.initState.fan.facebookId);
    _twitterEnabled = appBloc.initState.isArtist
        ? !StringUtils.isNullOrEmpty(appBloc.initState.artist.twitterId)
        : !StringUtils.isNullOrEmpty(appBloc.initState.fan.twitterId);
    _bio = appBloc.initState.isArtist ? appBloc.initState.artist.bio : "";
    _country = appBloc.initState.isArtist
        ? appBloc.initState.artist.country
        : appBloc.initState.fan.country;
    _countryIsoCode = appBloc.initState.isArtist
        ? appBloc.initState.artist.countryIsoCode
        : appBloc.initState.fan.countryIsoCode;

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

    _oldProfilePictureUrl = widget.isArtist
        ? appBloc.initState.artist.profilePictureUrl
        : appBloc.initState.fan.profilePictureUrl;
    _profilePictureUrl = widget.isArtist
        ? appBloc.initState.artist.profilePictureUrl
        : appBloc.initState.fan.profilePictureUrl;
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
    super.dispose();
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

      final sub = _bloc.edtProfileResult
          .listen((result) => _handleEditProfileResult(result, null));
      sub.onError((err) => _handleEditProfileResult(false, err));
      _subscriptions.add(sub);
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
      _buildEmail(),
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
    final editProfileTapHandler = TapGestureRecognizer();
    editProfileTapHandler.onTap = _editProfileInfo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
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
              backgroundImage: _newProfilePicture != null
                  ? FileImage(_newProfilePicture)
                  : (!StringUtils.isNullOrEmpty(_profilePictureUrl)
                      ? CachedNetworkImageProvider(_profilePictureUrl)
                      : MemoryImage(kTransparentImage)),
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
                    "$_displayName",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black87,
                      fontFamily: "SanFranciscoDisplay",
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    "@$_username",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                      fontFamily: "SanFranciscoDisplay",
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    _country,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black45,
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

  Widget _buildEmail() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Email",
          style: subHeaderTextStyle,
        ),
        SizedBox(height: 10.0),
        Text(
          _email,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black54,
            fontFamily: "SanFranciscoDisplay",
          ),
        ),
        SizedBox(height: 20.0),
      ],
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
    data.displayName = _displayName.trim();
    data.facebookId = _facebookId;
    data.twitterId = _twitterId;
    data.bio = _bio.trim();
    data.countryIsoCode = _editProfileInfoResult.countryIsoCode;
    data.profilePicture = _editProfileInfoResult.profilePicture;
    data.oldProfilePictureUrl = _oldProfilePictureUrl;
    data.removeFacebook = _initialFacebookEnabled == true &&
        _facebookEnabled == false &&
        StringUtils.isNullOrEmpty(_facebookId);
    data.removeTwitter = _initialTwitterEnabled == true &&
        _twitterEnabled == false &&
        StringUtils.isNullOrEmpty(_twitterId);
    hudOverlay = HudOverlay.showDefault(context);
    _bloc.editProfile.add(data);
  }

  void _editProfileInfo() async {
    final result = await Navigator.of(context).push<EditProfileInfoResult>(
      CupertinoPageRoute(
        builder: (ctx) => EditProfileInfoScreen(
              displayName: _displayName,
              countryIsoCode: _countryIsoCode,
              profileImageUrl: _profilePictureUrl,
            ),
      ),
    );
    if (result != null) {
      setState(() {
        _displayName = result.displayName;
        _country = result.country;
        _countryIsoCode = result.countryIsoCode;
        _editProfileInfoResult = result;
        _newProfilePicture = result.profilePicture;
      });
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

  void _handleEditProfileResult(bool success, String errorMessage) async {
    if (errorMessage != null) {
      hudOverlay?.close();
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(errorMessage),
      ));
    } else {
      final appBloc = BlocProvider.of<ApplicationBloc>(context);
      await appBloc.getAppInitState();
      setState(() {});
      // profile update successful
      hudOverlay?.close();
      Navigator.pop(context);
    }
  }
}
*/
