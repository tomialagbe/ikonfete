import 'package:flutter/material.dart';

class ArtistLoginScreen extends StatefulWidget {
  @override
  ArtistLoginScreenState createState() {
    return new ArtistLoginScreenState();
  }
}

class ArtistLoginScreenState extends State<ArtistLoginScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
