import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/utils/compressed_image_capture.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureChooser extends StatefulWidget {
  final Function(File) onImageSelected;
  final String imageUrl;

  ProfilePictureChooser({
    this.onImageSelected,
    this.imageUrl,
  });

  @override
  ProfilePictureChooserState createState() {
    return new ProfilePictureChooserState();
  }
}

class ProfilePictureChooserState extends State<ProfilePictureChooser> {
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    final uploadFileTapHandler = TapGestureRecognizer();
    uploadFileTapHandler.onTap = () async {
      final im = await CompressedImageCapture()
          .takePicture(context, ImageSource.gallery);
      setState(() => _imageFile = im);
      widget.onImageSelected(im);
    };

    final decorationImage = _imageFile != null
        ? DecorationImage(image: FileImage(_imageFile), fit: BoxFit.cover)
        : (!StringUtils.isNullOrEmpty(widget.imageUrl)
            ? DecorationImage(
                image: CachedNetworkImageProvider(widget.imageUrl),
                fit: BoxFit.cover)
            : null);

    final placeHolder = StringUtils.isNullOrEmpty(widget.imageUrl)
        ? ClipOval(
            child: Icon(
              FontAwesome5Icons.solidUser,
              color: primaryColor.withOpacity(0.5),
              size: 80.0,
            ),
          )
        : Container();

    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () async {
            final im = await CompressedImageCapture()
                .takePicture(context, ImageSource.camera);
            setState(() => _imageFile = im);
            widget.onImageSelected(im);
          },
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.4),
              shape: BoxShape.circle,
              image: decorationImage,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: placeHolder,
                ),
                Icon(
                  LineAwesomeIcons.camera,
                  color: Colors.white,
                  size: 40.0,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 5.0),
        Text("OR", style: TextStyle(fontSize: 14.0, color: Colors.black54)),
        SizedBox(height: 5.0),
        RichText(
          text: TextSpan(
            text: "Upload From File",
            recognizer: uploadFileTapHandler,
            style: TextStyle(
                fontSize: 14.0,
                color: primaryColor,
                decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
