import 'package:flutter/material.dart';

Widget artistHomeScreen(BuildContext context) {
  return ArtistHomeScreen();
}

class ArtistHomeScreen extends StatefulWidget {
  @override
  _ArtistHomeScreenState createState() => _ArtistHomeScreenState();
}

class _ArtistHomeScreenState extends State<ArtistHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text("Artist HOME"),
      ),
    );
  }
}
