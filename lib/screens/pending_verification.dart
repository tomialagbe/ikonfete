import 'dart:async';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/bloc/pending_verification_bloc.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/types/types.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class ArtistPendingVerificationScreen extends StatefulWidget {
  final String uid;

  ArtistPendingVerificationScreen({this.uid});

  @override
  _ArtistPendingVerificationScreenState createState() =>
      _ArtistPendingVerificationScreenState();
}

class _ArtistPendingVerificationScreenState
    extends State<ArtistPendingVerificationScreen> {
  ArtistPendingVerificationBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<ArtistPendingVerificationBloc>(context);
    _bloc.loadUserAction.add(null);
    _subscriptions.add(_bloc.logoutResult.listen(_handleLogoutResult));
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tapHandler = TapGestureRecognizer();
    tapHandler.onTap = () {};

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 4,
              child: StreamBuilder<Pair<FirebaseUser, Artist>>(
                stream: _bloc.loadUserResult,
                initialData: null,
                builder: (ctx, snapshot) {
                  return Container(
                    decoration: BoxDecoration(
                      color: colors.primaryColor,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        snapshot.hasData &&
                                !StringUtils.isNullOrEmpty(
                                    snapshot.data.first.photoUrl)
                            ? Image(
                                image:
                                    NetworkImage(snapshot.data.first.photoUrl),
                                fit: BoxFit.cover,
                              )
                            : Container(),
                        snapshot.hasData &&
                                !StringUtils.isNullOrEmpty(
                                    snapshot.data.first.photoUrl)
                            ? BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                    sigmaX: 10.0, sigmaY: 10.0),
                                child: Container(
                                  color: Colors.black.withOpacity(0.2),
                                  child: Container(),
                                ),
                              )
                            : Container(),
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 20.0,
                          right: MediaQuery.of(context).padding.right + 20.0,
                          child: IconButton(
                            icon: Icon(
                              LineAwesomeIcons.signOut,
                              color: Colors.white,
                            ),
                            onPressed: () => _bloc.logoutAction.add(null),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.5),
                              radius: 45.0,
                              backgroundImage: snapshot.hasData &&
                                      snapshot.data.first.photoUrl != null
                                  ? NetworkImage(snapshot.data.first.photoUrl)
                                  : null,
                              child: !snapshot.hasData ||
                                      snapshot.data.first.photoUrl == null
                                  ? Icon(
                                      FontAwesome5Icons.solidUser,
                                      size: 40.0,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              snapshot.hasData ? snapshot.data.second.name : "",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22.0),
                            ),
                            Text(
                              snapshot.hasData ? snapshot.data.first.email : "",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40.0, vertical: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
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
            PrimaryButton(
              width: MediaQuery.of(context).size.width - 80,
              height: 50.0,
              defaultColor: colors.primaryButtonColor,
              activeColor: colors.primaryButtonActiveColor,
              text: "SIGN OUT",
              // REGISTER
              onTap: () => _bloc.logoutAction.add(null),
            ),
            SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  void _handleLogoutResult(bool result) {
    Navigator.of(context).pop();
  }
}
