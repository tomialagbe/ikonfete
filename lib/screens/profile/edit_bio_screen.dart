import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class EditBioScreen extends StatefulWidget {
  final String bio;

  EditBioScreen({@required this.bio});

  @override
  _EditBioScreenState createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  String _bio;

  TextEditingController _bioTextController;

  @override
  void initState() {
    super.initState();
    _bio = widget.bio;
    _bioTextController = TextEditingController(text: _bio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          tooltip: "Back",
          onPressed: () {
            Navigator.pop(context, _bio);
          },
        ),
        title: Text(
          "Edit Bio",
          style: TextStyle(fontSize: 20.0, color: Colors.black45),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            color: Colors.black87,
            onPressed:
                _bioTextController.value.text == _bio ? null : _updateBio,
            tooltip: "Done",
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 20.0),
                child: LoginFormField(
                  controller: _bioTextController,
                  maxLines: null,
                ),
              ),
              PrimaryButton(
                width: MediaQuery.of(context).size.width - 40.0,
                height: 50.0,
                defaultColor: primaryButtonColor,
                activeColor: primaryButtonActiveColor,
                text: "Done",
                disabled: _bioTextController.value.text == _bio,
                onTap: _updateBio,
              ),
              SizedBox(height: 40.0)
            ],
          ),
        ),
      ),
    );
  }

  void _updateBio() {
    Navigator.of(context).pop(_bioTextController.value.text);
  }
}
