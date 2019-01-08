import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/screen_utils.dart';
import 'package:ikonfetemobile/screens/artist_verification/artist_verification_bloc.dart';
import 'package:ikonfetemobile/screens/artist_verification/artist_verification_events.dart';
import 'package:ikonfetemobile/screens/artist_verification/artist_verification_state.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:ikonfetemobile/widget/overlays.dart';

Widget artistVerificationScreen(BuildContext context, String uid) {
  return BlocProvider<ArtistVerificationBloc>(
    bloc: ArtistVerificationBloc(appConfig: AppConfig.of(context), uid: uid),
    child: ArtistVerificationScreen(),
  );
}

class ArtistVerificationScreen extends StatefulWidget {
  @override
  _ArtistVerificationScreenState createState() {
    return new _ArtistVerificationScreenState();
  }
}

class _ArtistVerificationScreenState extends State<ArtistVerificationScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final formKey = GlobalKey<FormState>();

  Future<bool> _willPop(BuildContext context) async {
    bool canClose = Navigator.canPop(context);
    return canClose;
  }

  @override
  Widget build(BuildContext context) {
    final artistVerificationBloc =
        BlocProvider.of<ArtistVerificationBloc>(context);
    return WillPopScope(
      onWillPop: () => _willPop(context),
      child: BlocBuilder<ArtistVerificationEvent, ArtistVerificationState>(
        bloc: artistVerificationBloc,
        builder: (BuildContext context, ArtistVerificationState state) {
          if (state.hasError) {
            ScreenUtils.onWidgetDidBuild(() {
              scaffoldKey.currentState
                  .showSnackBar(SnackBar(content: Text(state.errorMessage)));
            });
          } else if (state.pendingVerificationResult != null) {
            if (state.pendingVerificationResult.first) {
              ScreenUtils.onWidgetDidBuild(() {
                Navigator.of(context).pushReplacementNamed(
                    Routes.pendingVerification(
                        uid: artistVerificationBloc.uid));
              });
            } else {
              ScreenUtils.onWidgetDidBuild(() {
                scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text(state.pendingVerificationResult.second)));
              });
            }
          }

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
                  OverlayBuilder(
                    child: Container(),
                    showOverlay: state.isLoading,
                    overlayBuilder: (context) => HudOverlay.getOverlay(),
                  ),
                  _buildTitleAndBackButton(context),
                  SizedBox(height: 20.0),
                  _buildIntroText(),
                  SizedBox(height: 30.0),
                  ArtistVerificationForm(
                    formKey: formKey,
                    artistVerificationState: state,
                  ),
                  Expanded(child: Container()),
                  _buildButtons(context, state),
                  SizedBox(height: 40.0)
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
              "VERIFICATION",
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w100),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Navigator.canPop(context)
                ? IconButton(
                    icon: Icon(CupertinoIcons.back, color: Color(0xFF181D28)),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : Container(),
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

  Widget _buildButtons(BuildContext context, ArtistVerificationState state) {
    final artistVerificationBloc =
        BlocProvider.of<ArtistVerificationBloc>(context);
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
          text: "SUBMIT",
          // REGISTER
          onTap: () {
            if (formKey.currentState.validate()) {
              formKey.currentState.save();
              artistVerificationBloc.dispatch(SubmitVerification());
            }
          },
        ),
      ],
    );
  }
}

class ArtistVerificationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ArtistVerificationState artistVerificationState;

  const ArtistVerificationForm(
      {Key key, @required this.formKey, @required this.artistVerificationState})
      : super(key: key);

  @override
  _ArtistVerificationFormState createState() => _ArtistVerificationFormState();
}

class _ArtistVerificationFormState extends State<ArtistVerificationForm> {
  TextEditingController facebookTextController;
  TextEditingController twitterTextController;

  @override
  void initState() {
    super.initState();
    facebookTextController = TextEditingController();
    twitterTextController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final facebookSetup =
        !StringUtils.isNullOrEmpty(widget.artistVerificationState.facebookId);
    final twitterSetup =
        !StringUtils.isNullOrEmpty(widget.artistVerificationState.twitterId);

    if (facebookSetup) {
      facebookTextController.text = widget.artistVerificationState.facebookId;
    } else {
      facebookTextController.text = "";
    }

    if (twitterSetup) {
      twitterTextController.text =
          widget.artistVerificationState.twitterUsername;
    } else {
      twitterTextController.text = "";
    }

    final artistVerificationBloc =
        BlocProvider.of<ArtistVerificationBloc>(context);

    return Form(
      key: widget.formKey,
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
              onSaved: (String val) =>
                  artistVerificationBloc.dispatch(AddBio(val)),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildFacebookFormItem() {
    final verificationBloc = BlocProvider.of<ArtistVerificationBloc>(context);
    final facebookSetup =
        !StringUtils.isNullOrEmpty(widget.artistVerificationState.facebookId);

    return Row(
      key: UniqueKey(),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PrimaryButton(
          width: 50.0,
          height: 50.0,
          defaultColor: facebookColor,
          activeColor: facebookColor.withOpacity(0.7),
          child: Icon(ThemifyIcons.facebook, color: Colors.white),
          // REGISTER
          onTap: () => verificationBloc.dispatch(AddFacebook()),
        ),
        Padding(padding: EdgeInsets.only(right: 10.0)),
        Expanded(
          child: LoginFormField(
            placeholder: "Facebook ID",
            keyboardType: TextInputType.text,
            enabled: false,
            controller: facebookTextController,
            fillColor: !facebookSetup
                ? Colors.red.withOpacity(0.4)
                : facebookColor.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildTwitterFormItem() {
    final verificationBloc = BlocProvider.of<ArtistVerificationBloc>(context);
    final twitterSetup =
        !StringUtils.isNullOrEmpty(widget.artistVerificationState.twitterId);
    return Row(
      key: UniqueKey(),
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PrimaryButton(
          width: 50.0,
          height: 50.0,
          defaultColor: twitterColor,
          activeColor: twitterColor.withOpacity(0.7),
          child: Icon(ThemifyIcons.twitter, color: Colors.white),
          // REGISTER
          onTap: () => verificationBloc.dispatch(AddTwitter()),
        ),
        Padding(padding: EdgeInsets.only(right: 10.0)),
        Expanded(
          child: LoginFormField(
            placeholder: "Twitter Username",
            enabled: false,
            controller: twitterTextController,
            fillColor: !twitterSetup
                ? Colors.red.withOpacity(0.4)
                : twitterColor.withOpacity(0.4),
          ),
        ),
      ],
    );
  }
}
