import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/screens/logout_helper.dart';
import 'package:ikonfetemobile/screens/profile/artist_profile_header.dart';
import 'package:ikonfetemobile/screens/profile/artist_profile_screen_bloc.dart';

class ArtistProfileScreen extends StatefulWidget {
  final String uid;

  ArtistProfileScreen({this.uid});

  @override
  _ArtistProfileScreenState createState() => _ArtistProfileScreenState();
}

class _ArtistProfileScreenState extends State<ArtistProfileScreen>
    with TickerProviderStateMixin {
  bool isScrolledToTop;

  ArtistProfileScreenBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<ArtistProfileScreenBloc>(context);
      _bloc.loadArtist.add(widget.uid);
//      if (_subscriptions.isEmpty) {
//        _subscriptions.add(_bloc.loadArtistResult.listen(_artistLoaded));
//      }
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
    super.dispose();
  }

  Future<bool> _canLogout() async {
    bool logout = await canLogout(context);
    if (logout) {
      return await BlocProvider.of<ApplicationBloc>(context).doLogout();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final Size _screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: _canLogout,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              StreamBuilder<ArtistData>(
                stream: _bloc.loadArtistResult,
                initialData: null,
                builder: (ctx, snapshot) {
                  return SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    child: SliverPersistentHeader(
                      pinned: true,
                      delegate: ArtistProfileHeader(
                        artistName:
                            snapshot.hasData ? snapshot.data.artist.name : "",
                        artistScore: snapshot.hasData
                            ? snapshot.data.artist.feteScore ?? 0
                            : 0,
                        headerImageUrl: snapshot.hasData
                            ? snapshot.data.user.photoUrl
                            : null,
                        maxExtent: _screenSize.height / 2.9,
                        minExtent: 80.0,
                        onScroll: (double offset) {},
                        onScrollToTop: (bool isAtTop) {},
                        onBackPressed: () async {
                          bool canLogout = await _canLogout();
                          if (canLogout) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ];
          },
          body: Builder(
            builder: (BuildContext context) {
              return CustomScrollView(
                slivers: <Widget>[
                  new SliverOverlapInjector(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                  ),
                  _buildBody(),
                  _buildPopularTracksList()
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPopularTracksList() {
    return SliverPadding(
      padding: const EdgeInsets.all(25.0),
      sliver: SliverFixedExtentList(
        itemExtent: 64.0 + 20,
        delegate: new SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            return ListTile(
                contentPadding: EdgeInsets.all(0.0),
                leading: CircleAvatar(
                  radius: 32.0,
                  backgroundImage:
                      AssetImage('assets/images/onboard_background1.png'),
                ),
                title: Text(
                  'Music Title',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(Icons.more_vert),
                subtitle: Text(
                  'Albun 3:30',
                  style: TextStyle(
                    fontSize: 13.0,
                    color: Color(0xFF0707070),
                  ),
                ),
                enabled: true,
                onTap: () {
                  /* react to the tile being tapped */
                });
          },
          childCount: 10,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SliverPadding(
      padding: const EdgeInsets.all(25.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            SizedBox(
              height: 80.0,
            ),
            StreamBuilder<ArtistData>(
              stream: _bloc.loadArtistResult,
              initialData: null,
              builder: (ctx, snapshot) => _buildAboutArtist(
                  snapshot.hasData ? snapshot.data.artist.bio : ""),
            ),
            _buildArtistImages(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 42.0,
                ),
                Text(
                  "Popular Tracks",
                  style: TextStyle(
                    fontSize: 30.0,
                    fontFamily: "SanFranciscoDisplay",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistImages() {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0 / 1.0,
            child: GestureDetector(
              onTap: null,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/onboard_background1.png"),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
        ),

        //padding
        SizedBox(width: 13.0),

        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0 / 1.0,
            child: GestureDetector(
              onTap: null,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/onboard_background1.png"),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
        ),

        //padding
        SizedBox(width: 13.0),

        Expanded(
          child: AspectRatio(
            aspectRatio: 1.0 / 1.0,
            child: GestureDetector(
              onTap: null,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                        blueOverlay.withOpacity(0.5), BlendMode.multiply),
                    fit: BoxFit.cover,
                    image: AssetImage("assets/images/onboard_background1.png"),
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    "+5",
                    style: TextStyle(color: Colors.white, fontSize: 19.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutArtist(String bio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Text(
          "About The Artist",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 20.0,
            color: bodyColor,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 17.5),
          child: Text(
//            'Attention! Due to the change in the timing of the Central stadium "\Dynamo" concert Imagine Dragons August 29 in Moscow is transferred to a Large sports arena',
            bio,
            maxLines: 3,
            style: TextStyle(
              fontSize: 16.0,
              color: bodyColor,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: 17.5),
          child: GestureDetector(
            onTap: () {},
            child: Text(
              "Read More".toUpperCase(),
              style: TextStyle(color: primaryColor, fontSize: 15.0),
            ),
          ),
        ),
      ],
    );
  }

  void _artistLoaded(ArtistData artistData) {}
}
