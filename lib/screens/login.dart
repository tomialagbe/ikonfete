import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/login_bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

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
        _subscriptions
            .add(_bloc.artistLoginResult.listen(_handleArtistLoginResult));
        _subscriptions.add(_bloc.fanLoginResult.listen(_handleFanLoginResult));
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
      body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).viewInsets.top + 40.0,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _buildTitleAndBackButton(),
                SizedBox(height: 20.0),
                _buildIntroText(),
                SizedBox(height: 30.0),
                _buildForm(),
                SizedBox(height: 60.0),
                _buildButtons(),
              ],
            ),
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
              onPressed: () => Navigator.of(context).pop(),
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    recognizer: forgotPasswordTapHandler,
                    style: TextStyle(color: Color(0xFF999999), fontSize: 12.0),
                    text: "Forgotten Password?",
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
          onTap: null,
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
      _bloc.loginAction.add(null);
    }
  }

  void _handleArtistLoginResult(Triple<FirebaseUser, Artist, String> result) {
    hudOverlay?.close();
    if (result.first != null) {
      // login successful

      // check if user's account has been activated
      if (!result.first.isEmailVerified) {
        router.navigateTo(
          context,
          RouteNames.inactiveUser(uid: result.first.uid, isArtist: true),
          replace: false,
          transition: TransitionType.inFromRight,
        );
      } else {
        final artist = result.second;
        if (!artist.isVerified) {
          if (artist.isPendingVerification ?? false) {
            router.navigateTo(
              context,
              RouteNames.artistPendingVerification(uid: artist.uid),
              replace: false,
              transition: TransitionType.inFromRight,
            );
          } else {
            router.navigateTo(
              context,
              RouteNames.artistVerification(uid: artist.uid),
              replace: false,
              transition: TransitionType.inFromRight,
            );
          }
        } else {
          // artist is verified go to artist home page
          router.navigateTo(
            context,
            RouteNames.artistHome,
            transition: TransitionType.inFromRight,
            replace: false,
          );
        }
      }
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(result.third),
        ),
      );
    }
  }

  void _handleFanLoginResult(Triple<FirebaseUser, Fan, String> result) {
    hudOverlay?.close();
    if (result.first != null) {
      if (!result.first.isEmailVerified) {
        router.navigateTo(
          context,
          RouteNames.inactiveUser(uid: result.first.uid, isArtist: false),
          replace: false,
          transition: TransitionType.inFromRight,
        );
      } else {
        router.navigateTo(
          context,
          RouteNames.fanHome,
          replace: false,
          transition: TransitionType.inFromRight,
        );
      }
    }
  }
}
