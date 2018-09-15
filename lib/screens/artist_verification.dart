import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/artist_verification_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/pending_verification_screen_bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/screens/pending_verification.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class ArtistVerificationScreen extends StatefulWidget {
  final Artist artist;

  ArtistVerificationScreen({
    @required this.artist,
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
  ArtistVerificationBloc artistVerificationBloc;

  @override
  void initState() {
    super.initState();
    artistVerificationBloc = BlocProvider.of<ArtistVerificationBloc>(context);
    artistVerificationBloc.facebookActionResult.listen(_handleFacebookResult);
    artistVerificationBloc.twitterActionResult.listen(_handleTwitterResult);
    artistVerificationBloc.verifyActionResult.listen(_handleVerificationResult);
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
              SizedBox(height: 40.0),
              _buildButtons(),
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
              onSaved: (String val) => artistVerificationBloc.bio.add(val),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFacebookFormItem() {
    return StreamBuilder<FacebookActionResult>(
      stream: artistVerificationBloc.facebookActionResult,
      initialData: FacebookActionResult(),
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
              onTap: () => artistVerificationBloc.facebookAction.add(null),
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
    return StreamBuilder<TwitterActionResult>(
      stream: artistVerificationBloc.twitterActionResult,
      initialData: TwitterActionResult(),
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
              onTap: () => artistVerificationBloc.twitterAction.add(null),
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

  void _handleFacebookResult(FacebookActionResult result) {
    if (result.canceled) {
      return;
    }

    if (result.success) {
      facebookTextController.text = result.facebookUID;
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(result.errorMessage)),
      );
    }
  }

  void _handleTwitterResult(TwitterActionResult result) {
    if (result.canceled) {
      return;
    }

    if (result.success) {
      twitterTextController.text = result.twitterUsername;
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

    formKey.currentState.save();
    hudOverlay = HudOverlay.show(
        context, HudOverlay.dotsLoadingIndicator(), HudOverlay.defaultColor());
    artistVerificationBloc.uid = widget.artist.uid;
    artistVerificationBloc.verifyAction.add(null);
  }

  void _handleVerificationResult(Pair<bool, String> result) {
    hudOverlay?.close();
    if (result.first) {
      // take the user to the pending verification screen
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (_) => BlocProvider<ArtistPendingVerificationScreenBloc>(
                bloc:
                    ArtistPendingVerificationScreenBloc(uid: widget.artist.uid),
                child: ArtistPendingVerificationScreen(
                  artist: widget.artist,
                  newRequest: true,
                ),
              ),
        ),
      );
    } else {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(result.second)),
      );
    }
  }
}
