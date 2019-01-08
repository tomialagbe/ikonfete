import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/main_bloc.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/screens/artist_verification/artist_verification.dart';
import 'package:ikonfetemobile/screens/signup/activation.dart';
import 'package:ikonfetemobile/screens/signup/signup_bloc.dart';
import 'package:ikonfetemobile/screens/signup/signup_events.dart';
import 'package:ikonfetemobile/screens/signup/signup_state.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:ikonfetemobile/widget/overlays.dart';

Widget signupScreen(BuildContext context) {
  return BlocProvider<SignupBloc>(
    bloc: SignupBloc(
      appConfig: AppConfig.of(context),
    ),
    child: SignupScreen(),
  );
}

class SignupScreen extends StatelessWidget {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final appBloc = BlocProvider.of<AppBloc>(context);
    final signupBloc = BlocProvider.of<SignupBloc>(context);

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: BlocBuilder<SignupEvent, SignupState>(
        bloc: signupBloc,
        builder: (context, state) {
          if (state.signupResult != null) {
            final signupResult = state.signupResult;
            if (signupResult.success) {
              final uid = signupResult.isArtist
                  ? signupResult.artist.uid
                  : signupResult.fan.uid;
              if (signupResult.request.isEmailProvider) {
                _onWidgetDidBuild(() {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (ctx) {
                        return activationScreen(ctx, uid);
                      },
                    ),
                  );
                });
              } else {
                if (signupResult.isArtist) {
                  _onWidgetDidBuild(() {
                    Navigator.of(context).pushReplacement(CupertinoPageRoute(
                        builder: (ctx) => artistVerificationScreen(
                            ctx, signupResult.artist.uid)));
                  });
                } else {
                  // TODO:
                  // if fan, go to team selection
                }
              }
            } else {
              _onWidgetDidBuild(() {
                scaffoldKey.currentState.showSnackBar(
                    SnackBar(content: Text(signupResult.errorMessage)));
              });
            }
          }

          return Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewInsets.top + 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                OverlayBuilder(
                  child: Container(),
                  showOverlay: state.isLoading,
                  overlayBuilder: (context) => HudOverlay.getOverlay(),
                ),
                _buildTitleAndBackButton(context),
                SizedBox(height: 20.0),
                _buildIntroText(context),
                SizedBox(height: 30.0),
                BlocBuilder<AppEvent, AppState>(
                  bloc: appBloc,
                  builder: (context, state) {
                    return SignupForm(
                      isArtist: state.isArtist,
                      formKey: formKey,
                      onSwitchMode: (isArtist) {
                        appBloc.dispatch(SwitchMode(isArtist: isArtist));
                      },
                    );
                  },
                ),
                Expanded(child: Container()),
                _buildPolicyText(context),
                SizedBox(height: 10.0),
                BlocBuilder<AppEvent, AppState>(
                  bloc: appBloc,
                  builder: (context, state) {
                    return _buildButtons(context, state);
                  },
                ),
                SizedBox(height: 40.0),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
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
              AppLocalizations.of(context).welcome.toUpperCase(), // WELCOME
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w100),
            ),
          ],
        ),
        Navigator.of(context).canPop()
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(CupertinoIcons.back, color: Color(0xFF181D28)),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  Widget _buildIntroText(BuildContext context) {
    final appBloc = BlocProvider.of<AppBloc>(context);

    final tapHandler = TapGestureRecognizer();
    tapHandler.onTap =
        () => Navigator.pushReplacementNamed(context, Routes.login);

    final signInText = TextSpan(
      text: AppLocalizations.of(context).signIn, //"Sign in",
      recognizer: tapHandler,
      style: TextStyle(color: primaryColor),
    );

    final fanSignupIntroText = "Create an account to connect to\n"
        "your true favourite artist. Already have\n"
        "an account? "; // TODO: localize this text
    final artistSignupIntroText = AppLocalizations.of(context)
        .artistSignupIntroText; //Create an account to connect to\nyour awesome superfans. Already have\nan account?

    return BlocBuilder<AppEvent, AppState>(
      bloc: appBloc,
      builder: (context, state) {
        final signupIntroText =
            state.isArtist ? artistSignupIntroText : fanSignupIntroText;
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
      },
    );
  }

  Widget _buildPolicyText(BuildContext context) {
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
              color: primaryColor,
            ),
            recognizer: privacyPolicyTapHandler,
          ),
          TextSpan(text: " and "),
          TextSpan(
            text: "Terms of Service",
            style: TextStyle(
              color: primaryColor,
            ),
            recognizer: termsTapHandler,
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context, AppState state) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PrimaryButton(
          width: screenSize.width - 80,
          height: 50.0,
          defaultColor: primaryButtonColor,
          activeColor: primaryButtonActiveColor,
          text: AppLocalizations.of(context).register.toUpperCase(),
          // REGISTER
          onTap: () => _formSubmitted(context, state),
        ),
        _buildButtonSeparator(context),
        PrimaryButton(
          width: screenSize.width - 80,
          height: 50.0,
          defaultColor: Colors.white,
          activeColor: Colors.white70,
          elevation: 3.0,
          onTap: () => _doFacebookSignup(context, state),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: facebookColor,
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

  Widget _buildButtonSeparator(BuildContext context) {
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

  void _formSubmitted(BuildContext context, AppState appState) {
    final signupBloc = BlocProvider.of<SignupBloc>(context);
    bool valid = formKey.currentState.validate();
    if (valid) {
      formKey.currentState.save();
      signupBloc.dispatch(EmailSignup(isArtist: appState.isArtist));
    }
  }

  void _doFacebookSignup(BuildContext context, AppState appState) {
    final signupBloc = BlocProvider.of<SignupBloc>(context);
    signupBloc.dispatch(FacebookSignup(isArtist: appState.isArtist));
  }
}

class SignupForm extends StatefulWidget {
  final bool isArtist;
  final GlobalKey<FormState> formKey;
  final Function(bool) onSwitchMode;

  SignupForm({
    @required this.formKey,
    @required this.isArtist,
    this.onSwitchMode,
  });

  @override
  _SignupFormState createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  FocusNode nameFocusNode;
  FocusNode emailFocusNode;
  FocusNode passwordFocusNode;

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final switchModeTapHandler = TapGestureRecognizer();
    switchModeTapHandler.onTap = () {
      widget.onSwitchMode(!widget.isArtist);
    };

    final signupBloc = BlocProvider.of<SignupBloc>(context);

    return Form(
      key: widget.formKey,
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
              onSaved: (String val) =>
                  signupBloc.dispatch(NameEntered(val.trim())),
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
              onSaved: (val) => signupBloc.dispatch(EmailEntered(val.trim())),
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
              },
              onSaved: (val) =>
                  signupBloc.dispatch(PasswordEntered(val.trim())),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
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
}

/*
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
*/
