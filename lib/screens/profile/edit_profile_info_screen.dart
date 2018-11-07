import 'dart:io';

import 'package:country_code_picker/celement.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/screens/profile/profile_picture_chooser.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class EditProfileInfoResult {
  File profilePicture;
  String displayName;
  String countryIsoCode;
}

class EditProfileInfoScreen extends StatefulWidget {
  final String profileImageUrl;
  final String displayName;
  final String countryIsoCode;

  EditProfileInfoScreen({
    this.profileImageUrl,
    @required this.displayName,
    this.countryIsoCode,
  });

  @override
  _EditProfileInfoScreenState createState() => _EditProfileInfoScreenState();
}

class _EditProfileInfoScreenState extends State<EditProfileInfoScreen> {
  File _selectedImage;

//  Country _selectedCountry;
  CElement _selectedCountry;

  TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();
    _displayNameController =
        new TextEditingController(text: widget.displayName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black87,
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
            icon: Icon(Icons.check),
            color: Colors.black87,
            onPressed: _changesMade() ? _saveChanges : null,
            tooltip: "Done",
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
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
              imageUrl: widget.profileImageUrl,
            ),
            SizedBox(height: 40.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Display Name",
                  style: TextStyle(color: Colors.black54, fontSize: 16.0),
                ),
              ],
            ),
            SizedBox(height: 5.0),
            LoginFormField(
              controller: _displayNameController,
            ),
            SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Select Country",
                  style: TextStyle(color: Colors.black54, fontSize: 16.0),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CountryCodePicker(
                  onChanged: (newCountry) {
                    setState(() => _selectedCountry = newCountry);
                  },
                  padding: EdgeInsets.all(10.0),
                  textStyle: TextStyle(color: Colors.black54),
                ),
//                CountryPicker(
//                  onChanged: (Country newCountry) {
//                    setState(() => _selectedCountry = newCountry);
//                  },
//                  selectedCountry: _selectedCountry ?? Country.NG,
//                ),
                SizedBox(width: 10.0),
                Text(
                  _selectedCountry?.name ?? "Nigeria",
                  style: TextStyle(fontSize: 14.0, color: Colors.black54),
                ),
              ],
            ),
            Expanded(child: Container()),
            PrimaryButton(
              width: MediaQuery.of(context).size.width - 40.0,
              height: 50.0,
              defaultColor: primaryButtonColor,
              activeColor: primaryButtonActiveColor,
              text: "Done",
              disabled: !_changesMade(),
              onTap: _saveChanges,
            ),
            SizedBox(height: 20.0)
          ],
        ),
      ),
    );
  }

  bool _changesMade() {
    return _selectedImage != null ||
        _selectedCountry != null ||
        _displayNameController.value.text != widget.displayName;
  }

  void _saveChanges() {
    final result = EditProfileInfoResult()
      ..displayName = _displayNameController.value.text
      ..countryIsoCode = _selectedCountry?.code ?? null
      ..profilePicture = _selectedImage ?? null;
    Navigator.of(context).pop(result);
  }
}
