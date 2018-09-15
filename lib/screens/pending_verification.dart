import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/pending_verification_screen_bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/model/artist.dart';

class ArtistPendingVerificationScreen extends StatefulWidget {
  final bool newRequest;
  final Artist artist;

  ArtistPendingVerificationScreen({this.artist, this.newRequest});

  @override
  _ArtistPendingVerificationScreenState createState() =>
      _ArtistPendingVerificationScreenState();
}

class _ArtistPendingVerificationScreenState
    extends State<ArtistPendingVerificationScreen> {
  ArtistPendingVerificationScreenBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<ArtistPendingVerificationScreenBloc>(context);
    bloc.loadUserAction.add(null);
  }

  @override
  Widget build(BuildContext context) {
    final tapHandler = TapGestureRecognizer();
    tapHandler.onTap = () {};

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                color: colors.primaryColor,
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Thank you!",
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text("Once your email account is verified, we will\n"
                          "send you an email confirmation\n\n"
                          "In the meantime, you can connect your\n"
                          "streaming services to your profile."),
                      SizedBox(height: 30.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            LineAwesomeIcons.playCircle,
                            color: colors.primaryColor,
                            size: 24.0,
                          ),
                          SizedBox(width: 10.0),
                          RichText(
                            text: TextSpan(
                              recognizer: tapHandler,
                              text: "Connect Streaming Services",
                              style: TextStyle(
                                color: colors.primaryColor,
                                fontSize: 18.0,
                              ),
                            ),
                          )
                        ],
                      ),
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
}
