import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/auth_utils.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/login_bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/model/auth_type.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final bool isArtist;

  LoginScreen({
    @required this.isArtist,
  });

  @override
  _LoginScreenState createState() {
    return new _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  LoginBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FocusNode emailFocusNode;
  FocusNode passwordFocusNode;

  HudOverlay hudOverlay;

  @override
  void initState() {
    super.initState();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<LoginBloc>(context);
      if (_subscriptions.isEmpty) {
        _subscriptions.add(_bloc.loginResult.listen(_handleLoginResult));
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
      resizeToAvoidBottomPadding: false,
      key: scaffoldKey,
      body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewInsets.top + 40.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildTitleAndBackButton(),
              SizedBox(height: 20.0),
              _buildIntroText(),
              SizedBox(height: 30.0),
              _buildForm(),
              Expanded(child: Container()),
              _buildButtons(),
              SizedBox(height: 40.0),
            ],
          )),
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
              "LOGIN",
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
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildIntroText() {
    final tapHandler = TapGestureRecognizer();
    tapHandler.onTap = () => router.navigateTo(
        context, RouteNames.signup(isArtist: widget.isArtist),
        transition: TransitionType.inFromRight);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 14.0, color: Colors.black),
        text:
            "Welcome back...or welcome for the first\ntime. Either way, get in here!:)\n"
            "Don't have an account yet? ",
        children: <TextSpan>[
          TextSpan(
            text: "Sign Up",
            recognizer: tapHandler,
            style: TextStyle(color: colors.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final forgotPasswordTapHandler = TapGestureRecognizer();
    forgotPasswordTapHandler.onTap = () {}; // TODO: handle password reset

    final switchModeTapHandler = TapGestureRecognizer();
    switchModeTapHandler.onTap = () {
      SharedPreferences.getInstance().then(
          (prefs) => prefs.setBool(PreferenceKeys.isArtist, !widget.isArtist));
      router.navigateTo(
        context,
        RouteNames.login(isArtist: !widget.isArtist),
        replace: true,
        transition: TransitionType.inFromRight,
      );
    };

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LoginFormField(
              placeholder: "Email",
              focusNode: emailFocusNode,
              validator: FormFieldValidators.isValidEmail(),
              onFieldSubmitted: (newVal) {
                emailFocusNode.unfocus();
                FocusScope.of(context).requestFocus(passwordFocusNode);
              },
              onSaved: (String val) => _bloc.email.add(val),
            ),
            SizedBox(height: 20.0),
            LoginPasswordField(
              placeholder: "Password",
              focusNode: passwordFocusNode,
              textInputAction: TextInputAction.done,
              revealIcon: FontAwesome5Icons.eye,
              hideIcon: FontAwesome5Icons.eyeSlash,
              validator: FormFieldValidators.minLength("password", 6),
              onFieldSubmitted: (newVal) {
                passwordFocusNode.unfocus();
                _formSubmitted();
              },
              onSaved: (val) => _bloc.password.add(val),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    recognizer: forgotPasswordTapHandler,
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12.0,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                    text: "Forgotten Password?",
                  ),
                ),
                Expanded(child: Container()),
                RichText(
                  text: TextSpan(
                    recognizer: switchModeTapHandler,
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 12.0,
                      decoration: TextDecoration.underline,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                    text:
                        "Switch to ${widget.isArtist ? "Fan" : "Artist"} mode",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PrimaryButton(
          width: screenSize.width - 80,
          height: 50.0,
          defaultColor: colors.primaryButtonColor,
          activeColor: colors.primaryButtonActiveColor,
          text: "LOGIN",
          // REGISTER
          onTap: () => _formSubmitted(),
        ),
        _buildButtonSeparator(),
        PrimaryButton(
          width: screenSize.width - 80,
          height: 50.0,
          defaultColor: Colors.white,
          activeColor: Colors.white70,
          elevation: 3.0,
          onTap: () {
            hudOverlay = HudOverlay.show(context,
                HudOverlay.dotsLoadingIndicator(), HudOverlay.defaultColor());
            _bloc.loginAction.add(AuthActionRequest(
                userType:
                    widget.isArtist ? AuthUserType.artist : AuthUserType.fan,
                provider: AuthProvider.facebook));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.facebookColor,
                  ),
                  width: 25.0,
                  height: 25.0,
                  child: Icon(
                    ThemifyIcons.facebook,
                    color: Colors.white,
                    size: 15.0,
                  )),
              SizedBox(width: 10.0),
              Text("Facebook", style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtonSeparator() {
    final dividerColor = Color(0xFF707070);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              height: 1.0,
              color: dividerColor,
              margin: EdgeInsets.only(left: 40.0, right: 20.0),
            ),
          ),
          Text(AppLocalizations.of(context).or), // "or"
          Expanded(
            child: Container(
              height: 1.0,
              color: dividerColor,
              margin: EdgeInsets.only(right: 40.0, left: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  void _formSubmitted() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      hudOverlay = HudOverlay.show(context, HudOverlay.dotsLoadingIndicator(),
          HudOverlay.defaultColor());
      _bloc.loginAction.add(AuthActionRequest(
          userType: widget.isArtist ? AuthUserType.artist : AuthUserType.fan,
          provider: AuthProvider.email));
    }
  }

  void _handleLoginResult(LoginResult result) {
    final appBloc = BlocProvider.of<ApplicationBloc>(context);

    hudOverlay?.close();
    if (!result.success) {
      appBloc.doLogout();
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(result.errorMessage),
        ),
      );
    } else {
      final uid = result.isArtist ? result.artist.uid : result.fan.uid;
      bool isEmailActivated = result.request.isFacebookProvider ||
          (result.request.isEmailProvider &&
              result.firebaseUser.isEmailVerified);

      if (!isEmailActivated) {
        router.navigateTo(
          context,
          RouteNames.inactiveUser(uid: uid, isArtist: result.isArtist),
          replace: false,
          transition: TransitionType.inFromRight,
        );
      } else {
        bool isAccountVerified =
            result.isFan || (result.isArtist && result.artist.isVerified);
        if (!isAccountVerified) {
          if (result.artist.isPendingVerification) {
            router.navigateTo(
              context,
              RouteNames.artistPendingVerification(uid: uid),
              replace: false,
              transition: TransitionType.inFromRight,
            );
          } else {
            router.navigateTo(
              context,
              RouteNames.artistVerification(uid: uid),
              replace: false,
              transition: TransitionType.inFromRight,
            );
          }
        } else {
          // account is verified
          String routeName = widget.isArtist
              ? RouteNames.artistHome
              : (StringUtils.isNullOrEmpty(result
                      .fan.currentTeamId) // check if fan belongs to a team
                  ? RouteNames.teamSelection(uid: uid, name: result.fan.name)
                  : RouteNames.fanHome);
          router.navigateTo(
            context,
            routeName,
            transition: TransitionType.inFromRight,
            replace: false,
          );
        }
      }
    }
  }
}
