import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/model/SocialFeedItem.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/screens/home/fan_home_bloc.dart';
import 'package:ikonfetemobile/screens/home/widgets/social_cards.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/album_art.dart';
import 'package:ikonfetemobile/widget/artist_event.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';

enum HomeScreenTab { ArtistFeed, TeamFeed, Leaderboard }

class FanHomeScreen extends StatefulWidget {
  @override
  _FanHomeScreenState createState() => _FanHomeScreenState();
}

class _FanHomeScreenState extends State<FanHomeScreen>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Set<SocialFeedItem> _feedItems = SplayTreeSet<SocialFeedItem>();

  FanHomeBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];
  ScrollController _feedListScrollController = ScrollController();
  TabController _tabController;

  HomeScreenTab currentTab = HomeScreenTab.ArtistFeed;

  String fanUID;
  String currentTeamID;
  Artist artist;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.indexIsChanging) {
          if (_tabController.index == 0) {
            currentTab = HomeScreenTab.ArtistFeed;
          } else if (_tabController.index == 1) {
            currentTab = HomeScreenTab.TeamFeed;
          } else {
            currentTab = HomeScreenTab.Leaderboard;
          }
        }
      });
    });
    final appBloc = BlocProvider.of<ApplicationBloc>(context);
    fanUID = appBloc.initState.fan.uid;
    currentTeamID = appBloc.initState.fan.currentTeamId;
    _feedListScrollController.addListener(() {
      if (_feedListScrollController.position.maxScrollExtent -
              _feedListScrollController.offset <
          1000) {
        if (!_bloc.isLoading) {
          _loadMoreFeedItems();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_bloc == null) {
      _bloc = BlocProvider.of<FanHomeBloc>(context);
      _bloc.loadFollowedArtist(currentTeamId: currentTeamID);
      _subscriptions.add(_bloc.artistResult.listen((res) {
        this.artist = res;
        _bloc.loadSocialFeed(uid: fanUID, currentTeamId: currentTeamID);
      }));
      _subscriptions.add(_bloc.socialFeedItems.listen(_handleSocialFeedResult));
      _subscriptions
          .add(_bloc.socialFeedLoadErrors.listen(_handleSocialFeedErrors));
      _subscriptions
          .add(_bloc.facebookAuthResults.listen(_handleFacebookAuthResults));
    }
  }

  void _loadMoreFeedItems() {
    final facebookPagingToken = (_feedItems.lastWhere((item) {
      return (item is FacebookFeedItem) &&
          !StringUtils.isNullOrEmpty(item.pagingToken);
    }) as FacebookFeedItem)
        .pagingToken;

    final lastTweetIdStr =
        _feedItems.lastWhere((item) => item is TwitterFeedItem).id;
    final lastTweetId = int.parse(lastTweetIdStr);

    _bloc.loadSocialFeed(
      uid: fanUID,
      currentTeamId: currentTeamID,
      facebookPagingToken: facebookPagingToken,
      lastTweetId: lastTweetId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.only(top: MediaQuery.of(context).viewInsets.top),
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () async {
            _bloc.loadSocialFeed(uid: fanUID, currentTeamId: currentTeamID);
            return null;
          },
          child: ListView(
            controller: _feedListScrollController,
            children: <Widget>[
              SizedBox.fromSize(
                size: Size.fromHeight(250.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemExtent: 300.0,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  itemBuilder: (ctx, i) {
                    return ArtistEvent();
                  },
                ),
              ),
              _buildTabBar(),
              SizedBox(height: 10.0),
              _buildCurrentTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final labelTextStyle = TextStyle(
      fontFamily: "SanFranciscoDisplay",
      color: Colors.black54,
      fontWeight: FontWeight.bold,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 10.0, left: 20.0, right: 20.0),
      child: TabBar(
        labelStyle: labelTextStyle,
        labelColor: Colors.black54,
        unselectedLabelColor: Colors.black45,
        isScrollable: true,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: primaryColor,
            style: BorderStyle.solid,
            width: 2.0,
          ),
        ),
        tabs: <Widget>[
          Tab(text: "Artist Feed"),
          Tab(text: "Team Feed"),
          Tab(text: "Leaderboard"),
        ],
        controller: _tabController,
      ),
    );
  }

  Widget _buildArtistFeedContent() {
    final children = <Widget>[];
    children.addAll(_feedItems.map(_buildFeedItem));
    if (_bloc.isLoading) {
      children.add(_buildLoadingIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildAlbumList(),
        Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTab() {
    if (currentTab == HomeScreenTab.ArtistFeed) {
      return _buildArtistFeedContent();
    } else if (currentTab == HomeScreenTab.TeamFeed) {
      return Container();
    } else {
      return Container();
    }
  }

  Widget _buildAlbumList() {
    return Container(
      width: double.infinity,
      child: SizedBox.fromSize(
        size: Size.fromRadius(40.0),
        child: ListView.builder(
          padding: EdgeInsets.only(left: 20.0),
          scrollDirection: Axis.horizontal,
          itemExtent: 100.0, // MARGIN SIZE + WIDTH SIZE,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(right: 5.0, bottom: 10.0),
              child: AlbumArt(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedItem(SocialFeedItem item) {
    if (item is FacebookFeedItem) {
      return FacebookSocialCard(item, artist);
    } else {
      return TwitterSocialCard(item, artist);
    }
  }

  void _handleSocialFeedResult(List<SocialFeedItem> result) {
    _feedItems.addAll(result);
    setState(() {});
  }

  void _handleSocialFeedErrors(SocialFeedLoadError error) {
    if (error.type == SocialFeedLoadErrorType.facebookAuth) {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("You are not signed into facebook"),
        action: SnackBarAction(
            label: "SIGN IN",
            onPressed: () {
              _bloc.facebookAuth();
            }),
      ));
    }
  }

  void _handleFacebookAuthResults(FacebookAuthResult result) {
    if (result.success) {
      _bloc.loadSocialFeed(uid: fanUID, currentTeamId: currentTeamID);
    } else {
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(result.errorMessage),
        action: SnackBarAction(
            label: "RETRY",
            onPressed: () {
              _bloc.facebookAuth();
            }),
      ));
    }
  }

  Widget _buildLoadingIndicator() {
    return Opacity(
      opacity: 0.5,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 10.0),
        child: HudOverlay.dotsLoadingIndicator(),
      ),
    );
  }
}
