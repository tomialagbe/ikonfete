import 'dart:async';
import 'dart:io';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/user_signup_profile_bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/preferences.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/utils/compressed_image_capture.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSignupProfileScreen extends StatefulWidget {
  final bool isArtist;

  UserSignupProfileScreen({
    this.isArtist,
  });

  @override
  _UserSignupProfileScreenState createState() =>
      _UserSignupProfileScreenState();
}

class _UserSignupProfileScreenState extends State<UserSignupProfileScreen> {
  UserSignupProfileBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  File _displayPicture;
  bool _loadingPicture = false;

  Country _selectedDialogCountry = CountryPickerUtils.getCountryByIsoCode('ng');

  HudOverlay hudOverlay;

  FocusNode usernameFocusNode;

  @override
  void initState() {
    super.initState();
    usernameFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<UserSignupProfileBloc>(context);
      if (_subscriptions.isEmpty) {
        _subscriptions
            .add(_bloc.actionResult.listen(_handleProfileUpdateResult));
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
      resizeToAvoidBottomPadding: false,
      key: scaffoldKey,
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).viewInsets.top + 40.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildTitleAndBackButton(),
            SizedBox(height: 20.0),
            _buildIntroText(),
            SizedBox(height: 40.0),
            _buildForm(),
            Expanded(child: Container()),
            _buildButton(),
            SizedBox(height: 40.0),
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
              "YOU",
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
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
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
        text:
            "Select a display picture and username\nthat you will be identified with.",
      ),
    );
  }

  Widget _buildDialogItem(Country country) {
    return Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(width: 8.0),
        Flexible(child: Text(country.name)),
        SizedBox(width: 8.0),
        Text("(${country.isoCode})"),
      ],
    );
  }

  void _showCountryPickerDialog() {
    showDialog(
      context: context,
      builder: (context) => Theme(
            data: Theme.of(context).copyWith(primaryColor: Colors.pink),
            child: CountryPickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: Colors.pinkAccent,
              searchInputDecoration: InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              title: Text('Select your phone code'),
              onValuePicked: (Country country) => setState(() {
                    _bloc.countryCode.add(country.isoCode.toUpperCase());
                    _selectedDialogCountry = country;
                  }),
              itemBuilder: _buildDialogItem,
            ),
          ),
    );
  }

  Widget _buildForm() {
    final uploadImageHandler = TapGestureRecognizer();
    uploadImageHandler.onTap = () {
      _chooseDisplayPicture(ImageSource.gallery);
    };

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
                _chooseDisplayPicture(ImageSource.camera);
              },
              image: _displayPicture,
              isLoadingImage: _loadingPicture,
            ),
            SizedBox(height: 10.0),
            Text("OR"),
            SizedBox(height: 10.0),
            RichText(
              text: TextSpan(
                text: "Upload Image",
                style: TextStyle(
                  color: primaryColor,
                  decorationStyle: TextDecorationStyle.solid,
                  decoration: TextDecoration.underline,
                ),
                recognizer: uploadImageHandler,
              ),
            ),
            SizedBox(height: 40.0),
            LoginFormField(
              validator: FormFieldValidators.notEmpty("username"),
              focusNode: usernameFocusNode,
              placeholder: "Username",
              textAlign: TextAlign.center,
              textInputAction: TextInputAction.done,
              onSaved: (val) {
                _bloc.username.add(val.trim());
              },
              onFieldSubmitted: (val) {
                usernameFocusNode.unfocus();
              },
            ),
            SizedBox(height: 30.0),
            Text(
              "Select your country",
              style: TextStyle(fontSize: 14.0, color: Colors.black),
            ),
            SizedBox(height: 10.0),
            Material(
              child: InkWell(
                onTap: _showCountryPickerDialog,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CountryPickerUtils.getDefaultFlagImage(
                          _selectedDialogCountry),
                      SizedBox(width: 8.0),
                      Flexible(child: Text(_selectedDialogCountry.name)),
                      SizedBox(width: 8.0),
                      Text("(${_selectedDialogCountry.isoCode})"),
                    ],
                  ),
                ),
              ),
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
            if (_selectedDialogCountry == null) {
              scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text("Please select a country"),
                ),
              );
              return;
            }
            if (formKey.currentState.validate()) {
              formKey.currentState.save();
              hudOverlay = HudOverlay.show(context,
                  HudOverlay.dotsLoadingIndicator(), HudOverlay.defaultColor());
              if (_selectedDialogCountry != null) {
                _bloc.countryCode.add(_selectedDialogCountry.isoCode);
              }
              _bloc.action.add(null);
            }
          },
        ),
      ],
    );
  }

  Future _chooseDisplayPicture(ImageSource imageSource) async {
    setState(() {
      _loadingPicture = true;
    });
    final im = await CompressedImageCapture().takePicture(context, imageSource);
    setState(() {
      _loadingPicture = false;
      _displayPicture = im;
      _bloc.profilePicture.add(im);
    });
  }

  void _handleProfileUpdateResult(Pair<bool, String> result) async {
    if (!result.first) {
      hudOverlay?.close();
      scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(result.second)),
      );
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool(PreferenceKeys.isOnBoarded, true);
        prefs.setBool(PreferenceKeys.isArtist, widget.isArtist);
      });
      final appBloc = BlocProvider.of<ApplicationBloc>(context);
      final initState = await appBloc.getAppInitState();
      hudOverlay?.close();
      // if this is an artist, check if he's verified
      if (initState.isArtist) {
        if (initState.artist.isVerified) {
          router.navigateTo(
            context,
            RouteNames.artistHome,
            transition: TransitionType.inFromRight,
            replace: false,
          );
        } else if (initState.artist.isPendingVerification) {
          router.navigateTo(
            context,
            RouteNames.artistPendingVerification(uid: initState.artist.uid),
            replace: true,
            transition: TransitionType.inFromRight,
          );
        } else {
          router.navigateTo(
            context,
            RouteNames.artistVerification(uid: initState.artist.uid),
            replace: true,
            transition: TransitionType.inFromRight,
          );
        }
      } else if (StringUtils.isNullOrEmpty(initState.fan.currentTeamId)) {
        // if the user is a fan, check if the fan belongs to any team
        router.navigateTo(
          context,
          RouteNames.teamSelection(
              uid: initState.fan.uid, name: initState.fan.name),
          replace: true,
          transition: TransitionType.inFromRight,
        );
      } else {
        router.navigateTo(
          context,
          RouteNames.fanHome,
          replace: true,
          transition: TransitionType.inFromRight,
        );
      }
    }
  }
}

class ProfilePictureChooser extends StatelessWidget {
  final Function onTap;
  final File image;
  final bool isLoadingImage;

  ProfilePictureChooser({
    this.onTap,
    this.image,
    this.isLoadingImage,
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
            isLoadingImage
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor))
                : Container(),
          ],
        ),
      ),
    );
  }
}
