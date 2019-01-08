import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/main_bloc.dart';
import 'package:ikonfetemobile/screen_utils.dart';
import 'package:ikonfetemobile/screens/signup/activation_bloc.dart';
import 'package:ikonfetemobile/screens/signup/user_signup_profile.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:ikonfetemobile/widget/overlays.dart';

Widget activationScreen(BuildContext context, String uid) {
  return BlocProvider<ActivationBloc>(
    bloc: ActivationBloc(appConfig: AppConfig.of(context)),
    child: ActivationScreen(uid: uid),
  );
}

class ActivationScreen extends StatefulWidget {
  final String uid;

  ActivationScreen({@required this.uid});

  @override
  _ActivationScreenState createState() {
    return new _ActivationScreenState();
  }
}

class _ActivationScreenState extends State<ActivationScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final appBloc = BlocProvider.of<AppBloc>(context);
    final activationBloc = BlocProvider.of<ActivationBloc>(context);

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomPadding: false,
      body: BlocBuilder<ActivationEvent, ActivationState>(
        bloc: activationBloc,
        builder: (context, state) {
          if (state.activationResult != null) {
            final activationResult = state.activationResult;
            if (activationResult.first) {
              ScreenUtils.onWidgetDidBuild(() {
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                    builder: (ctx) {
                      return userSignupProfileScreen(ctx, widget.uid);
                    },
                  ),
                );
              });
            } else {
              ScreenUtils.onWidgetDidBuild(() {
                scaffoldKey.currentState.showSnackBar(
                    SnackBar(content: Text(activationResult.second)));
              });
            }
          }

          return Container(
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
                  OverlayBuilder(
                    child: Container(),
                    showOverlay: state.isLoading,
                    overlayBuilder: (context) => HudOverlay.getOverlay(),
                  ),
                  _buildTitleAndBackButton(context),
                  SizedBox(height: 20.0),
                  _buildIntroText(),
                  SizedBox(height: 40.0),
                  BlocBuilder<AppEvent, AppState>(
                    bloc: appBloc,
                    builder: (context, state) {
                      return ActivationForm(
                          formKey: formKey, isArtist: state.isArtist);
                    },
                  ),
                  SizedBox(height: 20.0),
                  BlocBuilder<AppEvent, AppState>(
                    bloc: appBloc,
                    builder: (context, state) {
                      return _buildButton(context, state);
                    },
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          );
        },
      ),
    );
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
              "ACTIVATION",
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

  Widget _buildIntroText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 14.0, color: Colors.black),
        //Create an account to connect to\nyour awesome superfans. Already have\nan account?
        text:
            "An activation code has been sent\nto your email. Enter the code you recieved \nto activate your account.",
      ),
    );
  }

  Widget _buildButton(BuildContext context, AppState appState) {
    final activationBloc = BlocProvider.of<ActivationBloc>(context);
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
          text: "ACTIVATE MY ACCOUNT",
          // REGISTER
          onTap: () {
            if (formKey.currentState.validate()) {
              formKey.currentState.save();
              activationBloc.dispatch(
                  ActivateUser(isArtist: appState.isArtist, uid: widget.uid));
            }
          },
        ),
        SizedBox(height: 30.0),
        _buildResendLink(),
      ],
    );
  }

  Widget _buildResendLink() {
    final tapHandler = TapGestureRecognizer();
    tapHandler.onTap = () => _resendActivation();
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 14.0, color: Colors.black),
        text: "Did not recieve the email?\n",
        children: [
          TextSpan(
            style: TextStyle(color: primaryColor),
            text: "Resend Email",
            recognizer: tapHandler,
          ),
        ],
      ),
    );
  }

  void _resendActivation() {}
}

class ActivationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool isArtist;

  const ActivationForm({
    this.formKey,
    this.isArtist,
  });

  @override
  _ActivationFormState createState() => _ActivationFormState();
}

class _ActivationFormState extends State<ActivationForm> {
  FocusNode codeFocusNode;

  @override
  void initState() {
    super.initState();
    codeFocusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    final activationBloc = BlocProvider.of<ActivationBloc>(context);
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            LoginFormField(
              focusNode: codeFocusNode,
              validator: FormFieldValidators.notEmpty("code"),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                LengthLimitingTextInputFormatter(6),
              ],
              textStyle: Theme.of(context).textTheme.body1.copyWith(
                    fontSize: 20.0,
                    letterSpacing: 10.0,
                  ),
              onFieldSubmitted: (_) {
                codeFocusNode.unfocus();
              },
              onSaved: (val) {
                activationBloc.dispatch(ActivationCodeEntered(
                    isArtist: widget.isArtist, code: val.trim()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
