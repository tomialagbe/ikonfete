import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/auth_utils.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/signup_bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/model/auth_type.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class SignupScreen extends StatefulWidget {
  final bool isArtist;
  final AppConfig appConfig;

  SignupScreen({
    @required this.isArtist,
    @required this.appConfig,
  });

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  SignupBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  FocusNode nameFocusNode;
  FocusNode emailFocusNode;
  FocusNode passwordFocusNode;

  HudOverlay hudOverlay;

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<SignupBloc>(context);
    _subscriptions.add(_bloc.signupResult.listen(_handleSignupResult));
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
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
              SizedBox(height: 30.0),
              _buildPolicyText(),
              SizedBox(height: 20.0),
              _buildButtons(),
              SizedBox(height: 40.0),
            ],
          ),
        ),
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
              AppLocalizations.of(context).welcome.toUpperCase(), // WELCOME
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
        context, RouteNames.login(isArtist: widget.isArtist),
        transition: TransitionType.inFromRight, replace: true);

    final signInText = TextSpan(
      text: AppLocalizations.of(context).signIn, //"Sign in",
      recognizer: tapHandler,
      style: TextStyle(color: colors.primaryColor),
    );

    final fanSignupIntroText = "Create an account to connect to\n"
        "your true favourite artist. Already have\n"
        "an account? "; // TODO: localize this text
    final artistSignupIntroText = AppLocalizations.of(context)
        .artistSignupIntroText; //Create an account to connect to\nyour awesome superfans. Already have\nan account?
    final signupIntroText =
        widget.isArtist ? artistSignupIntroText : fanSignupIntroText;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 14.0, color: Colors.black),
        text: signupIntroText,
        children: <TextSpan>[
          signInText,
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LoginFormField(
              placeholder: "Name",
              focusNode: nameFocusNode,
              validator: FormFieldValidators.notEmpty("name"),
              onFieldSubmitted: (newVal) {
                nameFocusNode.unfocus();
                FocusScope.of(context).requestFocus(emailFocusNode);
              },
              onSaved: (String val) => _bloc.name.add(val),
            ),
            SizedBox(height: 20.0),
            LoginFormField(
              placeholder: "Email",
              focusNode: emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              validator: FormFieldValidators.isValidEmail(),
              onFieldSubmitted: (newVal) {
                emailFocusNode.unfocus();
                FocusScope.of(context).requestFocus(passwordFocusNode);
              },
              onSaved: (val) => _bloc.email.add(val),
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
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyText() {
    final webviewAppBar = (String title) => AppBar(
          backgroundColor: Colors.white,
          elevation: 3.0,
          leading: IconButton(
            iconSize: 15.0,
            icon: Icon(
              ThemifyIcons.close,
              color: Color(0xFFAAAAAA),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        );

    final privacyPolicyTapHandler = TapGestureRecognizer();
    privacyPolicyTapHandler.onTap = () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => WebviewScaffold(
                  url: "http://ikonfete.com/privacy-policy",
                  appBar: webviewAppBar("Privacy Policy - Ikonfete"),
                ),
          ),
        );

    final termsTapHandler = TapGestureRecognizer();
    termsTapHandler.onTap = () => Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => WebviewScaffold(
                  url: "http://ikonfete.com/terms-of-use",
                  appBar: webviewAppBar("Terms of Use - Ikonfete"),
                ),
          ),
        );

    // TODO: localize this text
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 12.0, color: Colors.black),
        text: "By submitting this form, you agree to our\n",
        children: <TextSpan>[
          TextSpan(
            text: "Privacy Policy",
            style: TextStyle(
              color: colors.primaryColor,
            ),
            recognizer: privacyPolicyTapHandler,
          ),
          TextSpan(text: " and "),
          TextSpan(
            text: "Terms of Service",
            style: TextStyle(
              color: colors.primaryColor,
            ),
            recognizer: termsTapHandler,
          ),
        ],
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
          text: AppLocalizations.of(context).register.toUpperCase(),
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
          onTap: _doFacebookSignup,
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
    final overlayChild = HudOverlay.dotsLoadingIndicator();
    bool valid = formKey.currentState.validate();
    if (valid) {
      formKey.currentState.save();
      // do server side validation
      hudOverlay = HudOverlay.show(
        context,
        overlayChild,
        HudOverlay.defaultColor(),
      );

      final request = AuthActionRequest(
          userType: widget.isArtist ? AuthUserType.artist : AuthUserType.fan,
          provider: AuthProvider.email);
      _bloc.signup.add(request);
    }
  }

  void _doFacebookSignup() {
    hudOverlay = HudOverlay.show(
      context,
      HudOverlay.dotsLoadingIndicator(),
      HudOverlay.defaultColor(),
    );
    _bloc.signup.add(AuthActionRequest(
        userType: widget.isArtist ? AuthUserType.artist : AuthUserType.fan,
        provider: AuthProvider.facebook));
  }

  void _handleSignupResult(AuthResult result) {
    hudOverlay?.close();
    if (!result.success) {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(result.errorMessage),
        ),
      );
    } else {
      final uid = result.isArtist ? result.artist.uid : result.fan.uid;
      if (result.request.isEmailProvider) {
        // email signup
        router.navigateTo(
          context,
          RouteNames.activation(isArtist: result.isArtist, uid: uid),
          transition: TransitionType.inFromRight,
          replace: true,
        );
      } else {
        // facebook signup, no need for activation
        // take user to login
        showDialog(
          context: context,
          builder: (c) {
            return AlertDialog(
              title: Text("Signup Successful"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      "Congratulations. You have been successfuly signed up",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    // take artist to login page
                    if (result.request.isArtist) {
                      // to artist home page
                      router.navigateTo(
                        context,
                        RouteNames.login(isArtist: true),
                        replace: true,
                        transition: TransitionType.inFromRight,
                      );
                    } else {
                      // to team selection page
                      router.navigateTo(
                        context,
                        RouteNames.teamSelection(uid: uid),
                        replace: true,
                        transition: TransitionType.inFromRight,
                      );
                    }
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: colors.primaryColor),
                  ),
                ),
              ],
            );
          },
          barrierDismissible: false,
        );
      }
    }
  }
}
