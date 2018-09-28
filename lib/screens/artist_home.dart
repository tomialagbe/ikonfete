import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/routes.dart';

class ArtistHomeScreen extends StatefulWidget {
  @override
  _ArtistHomeScreenState createState() => _ArtistHomeScreenState();
}

class _ArtistHomeScreenState extends State<ArtistHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: FlatButton(onPressed: _logout, child: Text("LOGOUT")),
        ),
      ),
    );
  }

  void _logout() async {
    final appBloc = BlocProvider.of<ApplicationBloc>(context);
    await appBloc.doLogout();
    final loginRoute = RouteNames.login(isArtist: true);
    Navigator.pop(context);
//    Navigator.popUntil(context, ModalRoute.withName(loginRoute));
  }
}
