import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/screens/home/fan_home/artist_feed.dart';
import 'package:ikonfetemobile/screens/home/fan_home/artist_feed_bloc.dart';
import 'package:ikonfetemobile/screens/home/fan_home/fan_home_bloc.dart';
import 'package:ikonfetemobile/screens/home/fan_home/fan_home_events.dart';
import 'package:ikonfetemobile/screens/home/fan_home/fan_home_state.dart';
import 'package:ikonfetemobile/screens/home/leaderboard.dart';
import 'package:ikonfetemobile/screens/home/team_feed.dart';
import 'package:ikonfetemobile/widget/artist_event.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';

class FanHomeScreen extends StatefulWidget {
  final String fanUID;
  final String currentTeamID;
  final AppConfig appConfig;

  FanHomeScreen({
    Key key,
    @required this.fanUID,
    @required this.currentTeamID,
    @required this.appConfig,
  });

  @override
  _FanHomeScreenState createState() {
    return new _FanHomeScreenState();
  }
}

class _FanHomeScreenState extends State<FanHomeScreen>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollThreshold = 200.0;

  FanHomeBloc _fanHomeBloc;
  ArtistFeedBloc _artistFeedBloc;
  ScrollController _scrollController = ScrollController();
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fanHomeBloc = FanHomeBloc(appConfig: widget.appConfig);
    // load artist
    _fanHomeBloc
        .dispatch(FanHomeLoadArtistEvent(currentTeamId: widget.currentTeamID));

    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        int newIndex = _tabController.index;
        _fanHomeBloc.dispatch(SwitchTab(newTab: newIndex));
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _artistFeedBloc.dispatch(LoadFeed());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FanHomeEvent, FanHomeState>(
      bloc: _fanHomeBloc,
      builder: (BuildContext context, state) {
        Widget child;
        if (state.isArtistLoading) {
          return Center(
            child: HudOverlay.dotsLoadingIndicator(),
          );
        } else if (state.loadArtistFailed) {
          child = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.loadArtistError),
              SizedBox(height: 20),
              PrimaryButton(
                width: 200,
                height: 50,
                defaultColor: primaryColor,
                activeColor: primaryActiveColor,
                elevation: 3.0,
                onTap: () {
                  _fanHomeBloc.dispatch(FanHomeLoadArtistEvent(
                      currentTeamId: widget.currentTeamID));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Retry", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          );
        } else if (!state.isFacebookAuthorized) {
          return Container(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                PrimaryButton(
                  width: 200,
                  height: 50,
                  defaultColor: Colors.white,
                  activeColor: Colors.white70,
                  elevation: 3.0,
                  onTap: () {
                    _fanHomeBloc.dispatch(DoFacebookAuth());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: facebookColor,
                          ),
                          width: 25.0,
                          height: 25.0,
                          child: Icon(
                            ThemifyIcons.facebook,
                            color: Colors.white,
                            size: 15.0,
                          )),
                      SizedBox(width: 10.0),
                      Text("Sign in to Facebook",
                          style: TextStyle(color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // artist loaded successfully
          if (_artistFeedBloc == null) {
            _artistFeedBloc = ArtistFeedBloc(
                appConfig: widget.appConfig,
                artist: state.artist,
                fanUid: widget.fanUID,
                currentTeamId: widget.currentTeamID);
            _artistFeedBloc.dispatch(LoadFeed(refresh: true));
          }

          child = RefreshIndicator(
            onRefresh: () {
              _artistFeedBloc.dispatch(LoadFeed(refresh: true));
              return Future.value(null);
            },
            child: ListView(
              controller: _scrollController,
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
                _buildCurrentTab(state, state.activeTab),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          key: scaffoldKey,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            margin: EdgeInsets.only(top: MediaQuery.of(context).viewInsets.top),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
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

  Widget _buildCurrentTab(FanHomeState state, FanHomeActiveTab activeTab) {
    Widget tabContent;
    if (activeTab == FanHomeActiveTab.ArtistFeed) {
      tabContent = ArtistFeed(
        artistFeedBloc: _artistFeedBloc,
        artist: state.artist,
      );
    } else if (activeTab == FanHomeActiveTab.TeamFeed) {
      tabContent = TeamFeed();
    } else {
      tabContent = Leaderboard();
    }

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 1000),
      child: tabContent,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
