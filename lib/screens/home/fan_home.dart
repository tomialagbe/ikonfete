import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/widget/album_art.dart';
import 'package:ikonfetemobile/widget/artist_event.dart';
import 'package:ikonfetemobile/widget/ikonfete_buttons.dart';
import 'package:ikonfetemobile/widget/post_cards.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

final fanHomeScreen = Screen(
  title: "HOME",
  contentBuilder: (BuildContext context) {
    return FanHomeScreen();
  },
);

class FanHomeScreen extends StatefulWidget {
  @override
  _FanHomeScreenState createState() => _FanHomeScreenState();
}

class _FanHomeScreenState extends State<FanHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).viewInsets.top + 20.0,
      ),
      child: ListView(
        children: <Widget>[
          SizedBox.fromSize(
            size: Size.fromHeight(300.0),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemExtent: 300.0,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              itemBuilder: (ctx, i) {
                return ArtistEvent();
              },
            ),
          ),
          _buildTeamFeedTitle(),
          _buildAlbumList(),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                VideoPostCard(),
                MusicPostCard(),
                TextPostCard(),
                PrimaryButton(
                  text: "VIEW ALL",
                  height: 60.0,
                  onTap: () {},
                  width: double.infinity,
                  defaultColor: primaryColor,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTeamFeedTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                "Team Feed",
                style: TextStyle(
                  fontSize: 30.0,
                  fontFamily: "SanFranciscoDisplay",
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  "See all",
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: primaryColor),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            "New Releases, posts, events and more",
            style: TextStyle(
              color: Colors.black.withOpacity(0.64),
              fontSize: 15.0,
              fontFamily: "SanFranciscoDisplay",
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumList() {
    return SizedBox.fromSize(
        size: Size.fromHeight(100.0),
        child: ListView.builder(
          padding: EdgeInsets.only(left: 20.0),
          scrollDirection: Axis.horizontal,
          itemExtent: 100.0, // MARGIN SIZE + WIDTH SIZE,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: AlbumArt(),
            );
          },
        ));
  }
}
