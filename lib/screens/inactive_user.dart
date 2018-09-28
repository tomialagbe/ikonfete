import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/inactive_user_bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/localization.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class InactiveUserScreen extends StatefulWidget {
  final String uid;
  final bool isArtist;

  InactiveUserScreen({this.uid, this.isArtist});

  @override
  _InactiveUserScreenState createState() => _InactiveUserScreenState();
}

class _InactiveUserScreenState extends State<InactiveUserScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  InactiveUserScreenBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  HudOverlay hudOverlay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<InactiveUserScreenBloc>(context);
      if (_subscriptions.isEmpty) {
        _subscriptions.add(
            _bloc.resendActivationResult.listen(_handleResendActivationResult));
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SvgPicture.asset(
                    "assets/images/alert.svg",
                    height: 300.0,
                  ),
                  Text(
                    "Sorry. your account has not been activated. "
                        "But you can activate your account using the activation code"
                        " that was sent to your email adress when your registered.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  _buildButtons(),
                ],
              ),
            ),
          ),
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
            width: double.infinity,
            height: 50.0,
            defaultColor: colors.primaryButtonColor,
            activeColor: colors.primaryButtonActiveColor,
            text: "ACTIVATE MY ACCOUNT",
            // REGISTER
            onTap: _toActivationScreen),
        _buildButtonSeparator(),
        PrimaryButton(
          width: screenSize.width - 80,
          height: 50.0,
          defaultColor: Colors.white,
          activeColor: Colors.white70,
          textStyle: TextStyle(color: Colors.black),
          text: "RESEND THE ACTIVATION EMAIL",
          onTap: _resendActivation,
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

  void _toActivationScreen() {
    router.navigateTo(
      context,
      RouteNames.activation(isArtist: widget.isArtist, uid: widget.uid),
      replace: true,
      transition: TransitionType.inFromRight,
    );
  }

  void _resendActivation() {
    hudOverlay = HudOverlay.show(
        context, HudOverlay.dotsLoadingIndicator(), HudOverlay.defaultColor());
    _bloc.resendActivationAction.add(widget.uid);
  }

  void _handleResendActivationResult(Pair<bool, String> result) async {
    hudOverlay?.close();
    if (result.first) {
      _toActivationScreen();
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(result.second)),
      );
    }
  }
}
