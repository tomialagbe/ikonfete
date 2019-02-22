import 'dart:io';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dialog.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/screens/profile/profile_picture_chooser.dart';
import 'package:ikonfetemobile/screens/profile/profile_screen_bloc.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class EditProfileInfoResult {
  final File profilePicture;
  final String displayName;
  final String countryIsoCode;
  final String country;

  EditProfileInfoResult({
    this.profilePicture,
    this.displayName,
    this.countryIsoCode,
    this.country,
  });
}

class EditProfileInfoScreen extends StatefulWidget {
  final ProfileScreenBloc bloc;

  EditProfileInfoScreen({
    @required this.bloc,
  });

  @override
  _EditProfileInfoScreenState createState() => _EditProfileInfoScreenState();
}

class _EditProfileInfoScreenState extends State<EditProfileInfoScreen> {
  TextEditingController _displayNameController;
  File _selectedImage;
  Country _selectedDialogCountry;
  String _newDisplayName;

  @override
  void initState() {
    super.initState();
  }

  bool _changesMade(ProfileScreenState state) {
    return !StringUtils.isNullOrEmpty(_newDisplayName) ||
        _selectedImage != null ||
        (_selectedDialogCountry != null &&
            state.countryIsoCode.toLowerCase() !=
                _selectedDialogCountry.isoCode.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileScreenEvent, ProfileScreenState>(
      bloc: widget.bloc,
      builder: (BuildContext bldrContext, ProfileScreenState state) {
        if (_selectedDialogCountry == null &&
            !StringUtils.isNullOrEmpty(state.countryIsoCode)) {
          _selectedDialogCountry =
              CountryPickerUtils.getCountryByIsoCode(state.countryIsoCode);
        }

        if (_displayNameController == null) {
          _displayNameController = TextEditingController(
              text: StringUtils.isNullOrEmpty(state.newDisplayName)
                  ? state.displayName
                  : state.newDisplayName);
          _displayNameController.addListener(() {
            setState(() {
              _newDisplayName = _displayNameController.text;
            });
          });
        }

        return Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back),
              color: Colors.black54,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              "Edit Profile Info",
              style: TextStyle(fontSize: 20.0, color: Colors.black45),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(LineAwesomeIcons.check),
                color: Colors.black54,
                onPressed: _changesMade(state) ? _saveChanges : null,
                tooltip: "Done",
              ),
            ],
          ),
          body: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Click on the image below to update your profile picture",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 16.0),
                ),
                SizedBox(height: 10.0),
                ProfilePictureChooser(
                  onImageSelected: (File image) {
                    setState(() => _selectedImage = image);
                  },
                  imageUrl: state.profilePictureUrl,
                ),
                SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Display Name",
                      style: TextStyle(color: Colors.black54, fontSize: 16.0),
                    ),
                  ],
                ),
                SizedBox(height: 5.0),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 40.0),
                  child: LoginFormField(
                    controller: _displayNameController,
                    textAlign: TextAlign.center,
                    onSaved: (val) {
                      setState(() {
                        _newDisplayName = val;
                      });
                    },
                  ),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Select Country",
                      style: TextStyle(color: Colors.black54, fontSize: 16.0),
                    ),
                  ],
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
                          _selectedDialogCountry == null
                              ? Container()
                              : CountryPickerUtils.getDefaultFlagImage(
                                  _selectedDialogCountry),
                          SizedBox(width: 8.0),
                          Flexible(
                              child: Text(_selectedDialogCountry?.name ?? "")),
                          SizedBox(width: 8.0),
                          Text("(${_selectedDialogCountry?.isoCode ?? ""})"),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(child: Container()),
                PrimaryButton(
                  width: MediaQuery.of(context).size.width - 40.0,
                  height: 50.0,
                  defaultColor: primaryButtonColor,
                  activeColor: primaryButtonActiveColor,
                  text: "Done",
                  disabled: !_changesMade(state),
                  onTap: _saveChanges,
                ),
                SizedBox(height: 20.0)
              ],
            ),
          ),
        );
      },
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
              onValuePicked: (Country country) {
                setState(() {
                  _selectedDialogCountry = country;
                });
              },
              itemBuilder: _buildDialogItem,
            ),
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

  void _saveChanges() {
    Navigator.of(context).pop(EditProfileInfoResult(
      displayName: _newDisplayName,
      countryIsoCode: _selectedDialogCountry.isoCode,
      country: _selectedDialogCountry.name,
      profilePicture: _selectedImage,
    ));
  }
}
