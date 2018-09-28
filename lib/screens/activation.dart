import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ikonfetemobile/bloc/activation_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class ActivationScreen extends StatefulWidget {
  final bool isArtist;
  final String uid;

  ActivationScreen({
    @required this.isArtist,
    @required this.uid,
  });

  @override
  _ActivationScreenState createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  ActivationBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  HudOverlay hudOverlay;
  FocusNode codeFocusNode;
  bool resultListenerSet = false;

  @override
  void initState() {
    super.initState();
    codeFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<ActivationBloc>(context);
    _subscriptions.add(_bloc.result.listen(_handleActivationResult));
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
      resizeToAvoidBottomPadding: false,
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
              SizedBox(height: 40.0),
              _buildForm(),
              SizedBox(height: 20.0),
              _buildButton(),
              SizedBox(height: 20.0),
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
              "ACTIVATION",
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
              onSaved: (val) {
                _bloc.activationCode.add(val);
              },
              onFieldSubmitted: (_) {
                codeFocusNode.unfocus();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
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
          text: "ACTIVATE MY ACCOUNT",
          // REGISTER
          onTap: () => _activateUser(),
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
            style: TextStyle(color: colors.primaryColor),
            text: "Resend Email",
            recognizer: tapHandler,
          ),
        ],
      ),
    );
  }

  void _resendActivation() {}

  void _activateUser() {
    final overlayChild = HudOverlay.dotsLoadingIndicator();

    bool valid = formKey.currentState.validate();
    if (valid) {
      formKey.currentState.save();
      hudOverlay = HudOverlay.show(
        context,
        overlayChild,
        Colors.white.withOpacity(0.7),
      );

      _bloc.activate.add(null);
    }
  }

  void _handleActivationResult(Pair<bool, String> result) {
    hudOverlay?.close();
    if (result.first) {
      // take the user to the profile setup page
      router.navigateTo(
        context,
        RouteNames.signupProfile(isArtist: widget.isArtist, uid: widget.uid),
        transition: TransitionType.inFromRight,
        replace: true,
      );
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(result.second)),
      );
    }
  }
}
