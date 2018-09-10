import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/user_signup_profile_bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/routes.dart' as routes;
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSignupProfileScreen extends StatefulWidget {
  final Artist artist;
  final Fan fan;

  UserSignupProfileScreen({
    this.artist,
    this.fan,
  })  : assert(!(artist == null && fan == null)),
        assert(!(artist != null && fan != null));

  @override
  _UserSignupProfileScreenState createState() =>
      _UserSignupProfileScreenState();
}

class _UserSignupProfileScreenState extends State<UserSignupProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  File _displayPicture;

  HudOverlay hudOverlay;

  FocusNode usernameFocusNode;

  UserSignupProfileBloc bloc;

  @override
  void initState() {
    super.initState();
    usernameFocusNode = FocusNode();
    bloc = BlocProvider.of<UserSignupProfileBloc>(context);
    bloc.actionResult.listen(_handleProfileUpdateResult);
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
              SizedBox(height: 40.0),
              _buildForm(),
              SizedBox(height: 20.0),
              _buildButton(),
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
              "YOU",
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
        text:
            "Select a display picture and username\nthat you will be identified with.",
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
            ProfilePictureChooser(
              onTap: () {
                _chooseDisplayPicture();
              },
              image: _displayPicture,
            ),
            SizedBox(height: 40.0),
            LoginFormField(
              validator: FormFieldValidators.notEmpty("username"),
              focusNode: usernameFocusNode,
              placeholder: "Username",
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onSaved: (val) {
                bloc.username.add(val);
              },
              onFieldSubmitted: (val) {
                usernameFocusNode.unfocus();
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
          text: "PROCEED",
          // REGISTER
          onTap: () {
            if (formKey.currentState.validate()) {
              formKey.currentState.save();
              hudOverlay = HudOverlay.show(context,
                  HudOverlay.dotsLoadingIndicator(), HudOverlay.defaultColor());
              bloc.action.add(null);
            }
          },
        ),
      ],
    );
  }

  Future _chooseDisplayPicture() async {
    final im = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _displayPicture = im;
      bloc.profilePicture.add(im);
    });
  }

  void _handleProfileUpdateResult(Pair<bool, String> result) {
    hudOverlay?.close();
    if (!result.first) {
      scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(result.second)),
      );
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool(PreferenceKeys.isOnBoarded, true);
      });
      showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            title: Text("Onboarding Complete"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    "Congratulations. Your Ikonfete account has been setup.\nYou can now log in to your account",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushReplacementNamed(routes.artistLogin);
                },
                child: Text(
                  "LOGIN",
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

class ProfilePictureChooser extends StatelessWidget {
  final Function onTap;
  final File image;

  ProfilePictureChooser({
    this.onTap,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          color: colors.primaryColor.withOpacity(0.4),
          shape: BoxShape.circle,
          image: image == null
              ? null
              : DecorationImage(image: FileImage(image), fit: BoxFit.cover),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: image == null
                  ? ClipOval(
                      child: Icon(
                        FontAwesome5Icons.solidUser,
                        color: colors.primaryColor.withOpacity(0.5),
                        size: 80.0,
                      ),
                    )
                  : Container(),
            ),
            Icon(
              LineAwesomeIcons.camera,
              color: Colors.white,
              size: 40.0,
            ),
          ],
        ),
      ),
    );
  }
}
