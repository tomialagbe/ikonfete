import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/artist_verification_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/utils/twitter_auth.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class ArtistVerificationScreen extends StatefulWidget {
  final String uid;
  final String
      facebookLoginId; // the facebookLoginId for user's that sign up with facebook

  ArtistVerificationScreen({
    @required this.uid,
    this.facebookLoginId: "",
  });

  @override
  _ArtistVerificationScreenState createState() =>
      _ArtistVerificationScreenState();
}

class _ArtistVerificationScreenState extends State<ArtistVerificationScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();

  final facebookTextController = TextEditingController();
  final twitterTextController = TextEditingController();

  HudOverlay hudOverlay;

  ArtistVerificationBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  String _facebookId;
  String _twitterId;
  String _twitterUsername;
  String _bio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<ArtistVerificationBloc>(context);
      if (_subscriptions.isEmpty) {
        _subscriptions
            .add(_bloc.facebookActionResult.listen(_handleFacebookResult));
        _subscriptions
            .add(_bloc.twitterActionResult.listen(_handleTwitterResult));
        _subscriptions
            .add(_bloc.verifyActionResult.listen(_handleVerificationResult));
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
            SizedBox(height: 40.0)
          ],
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
              "VERIFICATION",
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
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(fontSize: 14.0, color: Colors.black),
        text: "Kindly provide additional information to\n"
            "get your account verified",
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
            _buildFacebookFormItem(),
            SizedBox(height: 20.0),
            _buildTwitterFormItem(),
            SizedBox(height: 20.0),
            LoginFormField(
              placeholder: "Bio",
              validator: FormFieldValidators.notEmpty("Bio"),
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.none,
              maxLines: 3,
              onSaved: (String val) => _bio = val,
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFacebookFormItem() {
    return StreamBuilder<FacebookAuthResult>(
      stream: _bloc.facebookActionResult,
      initialData: FacebookAuthResult(),
      builder: (ctx, snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            PrimaryButton(
              width: 50.0,
              height: 50.0,
              defaultColor: colors.facebookColor,
              activeColor: colors.facebookColor.withOpacity(0.7),
              child: Icon(ThemifyIcons.facebook, color: Colors.white),
              // REGISTER
              onTap: () => _bloc.facebookAction.add(null),
            ),
            Padding(padding: EdgeInsets.only(right: 10.0)),
            Expanded(
              child: LoginFormField(
                placeholder: "Facebook Username",
                keyboardType: TextInputType.text,
                enabled: false,
                controller: facebookTextController,
                fillColor: (!snapshot.data.success || snapshot.data.canceled)
                    ? Colors.red.withOpacity(0.4)
                    : colors.facebookColor.withOpacity(0.4),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTwitterFormItem() {
    return StreamBuilder<TwitterAuthResult>(
      stream: _bloc.twitterActionResult,
      initialData: TwitterAuthResult(),
      builder: (ctx, snapshot) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            PrimaryButton(
              width: 50.0,
              height: 50.0,
              defaultColor: colors.twitterColor,
              activeColor: colors.twitterColor.withOpacity(0.7),
              child: Icon(ThemifyIcons.twitter, color: Colors.white),
              // REGISTER
              onTap: () => _bloc.twitterAction.add(null),
            ),
            Padding(padding: EdgeInsets.only(right: 10.0)),
            Expanded(
              child: LoginFormField(
                placeholder: "Twitter Username",
                enabled: false,
                controller: twitterTextController,
                fillColor: (!snapshot.data.success || snapshot.data.canceled)
                    ? Colors.red.withOpacity(0.4)
                    : colors.twitterColor.withOpacity(0.4),
              ),
            ),
          ],
        );
      },
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
          text: "SUBMIT",
          // REGISTER
          onTap: _handleSubmit,
        ),
      ],
    );
  }

  void _handleFacebookResult(FacebookAuthResult result) {
    if (result.canceled) {
      return;
    }

    if (result.success) {
      facebookTextController.text = result.facebookUID;
      _facebookId = result.facebookUID;
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(result.errorMessage)),
      );
    }
  }

  void _handleTwitterResult(TwitterAuthResult result) {
    if (result.canceled) {
      return;
    }

    if (result.success) {
      twitterTextController.text = result.twitterUsername;
      _twitterId = result.twitterUID;
      _twitterUsername = result.twitterUsername;
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(result.errorMessage),
        ),
      );
    }
  }

  void _handleSubmit() async {
    if (!formKey.currentState.validate()) {
      return;
    }
    if (StringUtils.isNullOrEmpty(_facebookId) ||
        StringUtils.isNullOrEmpty(_twitterId) ||
        StringUtils.isNullOrEmpty(_twitterUsername)) {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content:
              Text("Your Facebook and Twitter accounts have not been setup"),
        ),
      );
      return;
    }

    formKey.currentState.save();
    hudOverlay = HudOverlay.show(
        context, HudOverlay.dotsLoadingIndicator(), HudOverlay.defaultColor());

    final params = VerifyParams()
      ..uid = widget.uid
      ..fbId = _facebookId
      ..twitterId = _twitterId
      ..twitterUsername = _twitterUsername
      ..bio = _bio;
    _bloc.verifyAction.add(params);
  }

  void _handleVerificationResult(Pair<bool, String> result) {
    hudOverlay?.close();
    if (result.first) {
      // take the user to the pending verification screen
      router.navigateTo(
          context, RouteNames.artistPendingVerification(uid: widget.uid),
          replace: true, transition: TransitionType.inFromRight);
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(result.second)),
      );
    }
  }
}
