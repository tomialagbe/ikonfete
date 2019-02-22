import 'package:flutter/material.dart';

class ArtistEvent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.bottomLeft,
          margin: EdgeInsets.only(right: 15.0),
          padding: EdgeInsets.all(15.0),
          height: 160.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 3.0,
                spreadRadius: 1.0,
                offset: Offset(0.0, 2.0),
              ),
            ],
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/onboard_background1.png"),
            ),
          ),
          child: Row(
            children: [
              _buildTag(context),
              _buildTag(context),
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Text(
          "Concert Name",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 20.0,
            fontFamily: "SanFranciscoDisplay",
            fontWeight: FontWeight.bold,
            color: Color(0xAA000000),
          ),
        ),
        Text(
          "Concert Address & Venue Here ",
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black.withOpacity(0.64),
            fontSize: 14.0,
            fontFamily: "SanFranciscoDisplay",
          ),
        ),
        Text(
          "Concert Date & Time Here ",
          textAlign: TextAlign.start,
          style: TextStyle(
            color: Colors.black.withOpacity(0.64),
            fontSize: 14.0,
            fontFamily: "SanFranciscoDisplay",
          ),
        ),
      ],
    );
  }

  Widget _buildTag(context) {
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 6.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      child: Text(
        "CONCERT",
        style: Theme.of(context).textTheme.body1.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
