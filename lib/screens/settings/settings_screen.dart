//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:ikonfetemobile/bloc/bloc.dart';
//import 'package:ikonfetemobile/main_bloc.dart';
//import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/main_bloc.dart';
import 'package:ikonfetemobile/screens/settings/settings_bloc.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:ikonfetemobile/widget/overlays.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

final Screen settingsScreen = Screen(
  title: "Settings",
  contentBuilder: (context) {
    final appBloc = BlocProvider.of<AppBloc>(context);
    return BlocBuilder<AppEvent, AppState>(
      bloc: appBloc,
      builder: (bldContet, appState) {
        return BlocProvider<SettingsBloc>(
          bloc: SettingsBloc(
            appConfig: AppConfig.of(context),
//        deezerAuthBloc: DeezerAuthBloc(),
//        spotifyAuthBloc: SpotifyAuthBloc(),
          ),
          child: SettingsScreen(uid: appState.uid),
        );
      },
    );
  },
);

class SettingsScreen extends StatefulWidget {
  final String uid;

  SettingsScreen({this.uid});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final settingHeaderTextStyle = TextStyle(
    fontFamily: "SanFranciscoDisplay",
    fontSize: 18.0,
    color: Colors.black87,
  );

  final settingInfoTextStyle = TextStyle(
    fontFamily: "SanFranciscoDisplay",
    fontSize: 14.0,
    color: Colors.black54,
  );

  @override
  void initState() {
    super.initState();
    SettingsBloc bloc = BlocProvider.of<SettingsBloc>(context);
    bloc.dispatch(LoadSettingsEvent(widget.uid));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<SettingsBloc>(context);
    return Scaffold(
      key: scaffoldKey,
      body: BlocBuilder<SettingsEvent, SettingsState>(
        bloc: bloc,
        builder: (bldContext, settingsState) {
          if (settingsState.hasError) {
            scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text(settingsState.errorMessage)));
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                OverlayBuilder(
                  child: Container(),
                  showOverlay: settingsState.isLoading,
                  overlayBuilder: (context) => HudOverlay.getOverlay(),
                ),
                Text(
                  "Connected Social Profiles",
                  style: settingHeaderTextStyle,
                ),
                SizedBox(height: 30.0),
                _buildSoundCloudConnector(),
                SizedBox(height: 30.0),
                _buildSpotifyConnector(settingsState),
                SizedBox(height: 30.0),
                _buildDeezerConnector(settingsState),
                SizedBox(height: 40.0),
                _buildNotificationSettings(),
                SizedBox(height: 30.0),
                _buildAboutLink(),
                Expanded(child: Container()),
                _buildSaveButton(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSoundCloudConnector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: soundCloudColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Icon(FontAwesome5Icons.soundCloud, color: Colors.white),
        ),
        SizedBox(width: 20.0),
        Text("SoundCloud", style: settingHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
//          value: _soundCloudEnabled, TODO:
          value: false,
          onChanged: (val) {},
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildSpotifyConnector(SettingsState settingsState) {
    final bloc = BlocProvider.of<SettingsBloc>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: spotifyColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Icon(FontAwesome5Icons.spotify, color: Colors.white),
        ),
        SizedBox(width: 20.0),
        Text("Spotify", style: settingHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
//          value: _spotifyEnabled, TODO:
          value:
              !StringUtils.isNullOrEmpty(settingsState.settings.spotifyUserId),
          onChanged: (val) async {
//            setState(() => _spotifyEnabled = val);
//            if (val) {
//              _bloc.spotifyAuthBloc.authorizeSpotify();
//            } else if (_settings != null) {
//              _settings.spotifyUserId = "";
//            }
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildDeezerConnector(SettingsState settingsState) {
    final bloc = BlocProvider.of<SettingsBloc>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40.0,
          height: 40.0,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: Color(0xFF162737),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Image.asset("assets/images/deezer.png", fit: BoxFit.contain),
        ),
        SizedBox(width: 20.0),
        Text("Deezer", style: settingHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
//          value: _deezerEnabled, TODO:
          value:
              !StringUtils.isNullOrEmpty(settingsState.settings.deezerUserId),
          onChanged: (val) async {
            if (val) {
              bloc.dispatch(EnableDeezerEvent());
            }
//            setState(() => _deezerEnabled = val);
//            if (val) {
//              _bloc.deezerAuthBloc.authorizeDeezer();
//            } else if (_settings != null) {
//              _settings.deezerUserId = "";
//            }
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications",
                style: settingHeaderTextStyle,
              ),
              SizedBox(height: 5.0),
              Text(
                "We send notifications about new tracks, albums and other important things",
                style: settingInfoTextStyle,
              ),
            ],
          ),
        ),
        SizedBox(width: 5.0),
        CupertinoSwitch(
//          value: _notificationsEnabled, TODO:
          value: false,
          onChanged: (val) {
//            setState(() {
//              _notificationsEnabled = val;
//            });
//            _settings?.enableNotifications = val;
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildAboutLink() {
    final aboutTapHandler = TapGestureRecognizer();
    aboutTapHandler.onTap = () {};

    return RichText(
      text: TextSpan(
        text: "About Ikonfete",
        style: settingHeaderTextStyle,
        recognizer: aboutTapHandler,
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return PrimaryButton(
      width: MediaQuery.of(context).size.width - 40.0,
      height: 50.0,
      defaultColor: primaryButtonColor,
      activeColor: primaryButtonActiveColor,
      text: "SAVE SETTINGS",
//      disabled: !_changesMade(), TODO:
      disabled: false,
//      onTap: _saveChanges,
      onTap: () {},
    );
  }
}

/*class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final settingHeaderTextStyle = TextStyle(
    fontFamily: "SanFranciscoDisplay",
    fontSize: 18.0,
    color: Colors.black87,
  );

  final settingInfoTextStyle = TextStyle(
    fontFamily: "SanFranciscoDisplay",
    fontSize: 14.0,
    color: Colors.black54,
  );

  SettingsBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];
  ApplicationBloc _appBloc;

  bool _deezerEnabled = false;
  bool _spotifyEnabled = false;
  bool _soundCloudEnabled = false;
  bool _notificationsEnabled = false;

  bool _initialDeezerEnabled;
  bool _initialSpotifyEnabled;
  bool _initialSoundCloudEnabled;
  bool _initialNotificationsEnabled;

  Settings _settings;
  bool _settingsLoading = true;
  bool _loadSettingsFailed = false;

  HudOverlay hudOverlay;

  @override
  void initState() {
    super.initState();
    _appBloc = BlocProvider.of<ApplicationBloc>(context);
    if (_bloc == null) {
      _bloc = BlocProvider.of<SettingsBloc>(context);
      _bloc.loadSettings(_appBloc.initState.currentUser.uid);
      if (_subscriptions.isEmpty) {
        _subscriptions
            .add(_bloc.loadSettingsResult.listen(_handleLoadSettingsResult)
              ..onError((err) {
                _showErrorSnackBar(err);
                setState(() {
                  _settingsLoading = false;
                  _loadSettingsFailed = true;
                });
              }));
        _subscriptions.add(_bloc.deezerAuthBloc.deezerAuthResult
            .listen(_handleDeezerAuthResult)
              ..onError((err) {
                setState(() {
                  _deezerEnabled = false;
                });
                _showErrorSnackBar(err);
              }));
        _subscriptions.add(_bloc.spotifyAuthBloc.spotifyAuthResult
            .listen(_handleSpotifyAuthResult)
              ..onError((err) {
                setState(() {
                  _spotifyEnabled = false;
                });
                _showErrorSnackBar(err);
              }));
        _subscriptions
            .add(_bloc.saveSettingsResult.listen(_handleSaveSettingsResult)
              ..onError((err) {
                hudOverlay?.close();
              }));
      }
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
        child: _settingsLoading
            ? _buildLoadingIndicator()
            : _loadSettingsFailed
                ? _buildLoadSettingsError()
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Connected Social Profiles",
                        style: settingHeaderTextStyle,
                      ),
                      SizedBox(height: 30.0),
                      _buildSoundCloudConnector(),
                      SizedBox(height: 30.0),
                      _buildSpotifyConnector(),
                      SizedBox(height: 30.0),
                      _buildDeezerConnector(),
                      SizedBox(height: 40.0),
                      _buildNotificationSettings(),
                      SizedBox(height: 30.0),
                      _buildAboutLink(),
                      Expanded(child: Container()),
                      _buildSaveButton(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      alignment: Alignment.center,
      child: HudOverlay.dotsLoadingIndicator(),
    );
  }

  Widget _buildLoadSettingsError() {
    final reloadTapHandler = TapGestureRecognizer();
    reloadTapHandler.onTap = () {
      _bloc.loadSettings(_appBloc.initState.currentUser.uid);
      setState(() {
        _settingsLoading = true;
        _loadSettingsFailed = false;
      });
    };
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: "Failed to load Settings\n",
            style: TextStyle(color: Colors.black54, fontSize: 18.0),
            children: [
              TextSpan(
                text: "Try Again",
                recognizer: reloadTapHandler,
                style: TextStyle(
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundCloudConnector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: soundCloudColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Icon(FontAwesome5Icons.soundCloud, color: Colors.white),
        ),
        SizedBox(width: 20.0),
        Text("SoundCloud", style: settingHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
          value: _soundCloudEnabled,
          onChanged: (val) {},
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildSpotifyConnector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: spotifyColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Icon(FontAwesome5Icons.spotify, color: Colors.white),
        ),
        SizedBox(width: 20.0),
        Text("Spotify", style: settingHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
          value: _spotifyEnabled,
          onChanged: (val) async {
            setState(() => _spotifyEnabled = val);
            if (val) {
              _bloc.spotifyAuthBloc.authorizeSpotify();
            } else if (_settings != null) {
              _settings.spotifyUserId = "";
            }
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildDeezerConnector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 40.0,
          height: 40.0,
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: Color(0xFF162737),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Image.asset("assets/images/deezer.png", fit: BoxFit.contain),
        ),
        SizedBox(width: 20.0),
        Text("Deezer", style: settingHeaderTextStyle),
        Expanded(child: Container()),
        CupertinoSwitch(
          value: _deezerEnabled,
          onChanged: (val) async {
            setState(() => _deezerEnabled = val);
            if (val) {
              _bloc.deezerAuthBloc.authorizeDeezer();
            } else if (_settings != null) {
              _settings.deezerUserId = "";
            }
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications",
                style: settingHeaderTextStyle,
              ),
              SizedBox(height: 5.0),
              Text(
                "We send notifications about new tracks, albums and other important things",
                style: settingInfoTextStyle,
              ),
            ],
          ),
        ),
        SizedBox(width: 5.0),
        CupertinoSwitch(
          value: _notificationsEnabled,
          onChanged: (val) {
            setState(() {
              _notificationsEnabled = val;
            });
            _settings?.enableNotifications = val;
          },
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildAboutLink() {
    final aboutTapHandler = TapGestureRecognizer();
    aboutTapHandler.onTap = () {};

    return RichText(
      text: TextSpan(
        text: "About Ikonfete",
        style: settingHeaderTextStyle,
        recognizer: aboutTapHandler,
      ),
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

  bool _changesMade() {
    return _soundCloudEnabled != _initialSoundCloudEnabled ||
        _spotifyEnabled != _initialSpotifyEnabled ||
        _deezerEnabled != _initialDeezerEnabled ||
        _notificationsEnabled != _initialNotificationsEnabled;
  }

  void _saveChanges() async {
    _settings.uid = _appBloc.initState.currentUser.uid;
    hudOverlay = HudOverlay.showDefault(context);
    _bloc.updateSettings(_settings);
  }

  void _handleLoadSettingsResult(Settings settings) {
    setState(() {
      _settingsLoading = false;
      _loadSettingsFailed = false;

      _settings = settings != null ? settings : Settings.empty();
      _soundCloudEnabled = false;
      _deezerEnabled = !StringUtils.isNullOrEmpty(_settings.deezerUserId);
      _spotifyEnabled = !StringUtils.isNullOrEmpty(_settings.spotifyUserId);
      _notificationsEnabled = _settings.enableNotifications;

      _initialSoundCloudEnabled = _soundCloudEnabled;
      _initialDeezerEnabled = _deezerEnabled;
      _initialSpotifyEnabled = _spotifyEnabled;
      _initialNotificationsEnabled = _notificationsEnabled;
    });
  }

  void _handleDeezerAuthResult(DeezerUser user) {
    setState(() {
      _settings.deezerUserId = user.id.toString();
    });
  }

  void _handleSpotifyAuthResult(SpotifyUser user) {
    setState(() {
      _settings.spotifyUserId = user.id;
    });
  }

  void _handleSaveSettingsResult(Settings settings) {
    hudOverlay?.close();
    ZoomScaffoldScreenState zoomScaffoldScreenState =
        context.ancestorStateOfType(ZoomScaffoldStateTypeMatcher());
    zoomScaffoldScreenState.changeActiveScreen(MenuIDs.home);
  }

  void _showErrorSnackBar(Object errMessage) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(errMessage.toString()), backgroundColor: Colors.red));
  }
}
*/
