import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/social_feed_item.dart';
import 'package:ikonfetemobile/screens/home/fan_home/artist_feed_bloc.dart';
import 'package:ikonfetemobile/screens/home/widgets/social_cards.dart';
import 'package:ikonfetemobile/widget/album_art.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';

class ArtistFeed extends StatelessWidget {
  final ArtistFeedBloc artistFeedBloc;
  final Artist artist;

  ArtistFeed({@required this.artistFeedBloc, this.artist});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildAlbumList(),
        BlocBuilder<ArtistFeedEvent, ArtistFeedState>(
          bloc: artistFeedBloc,
          builder: (context, ArtistFeedState state) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: state.feedItems.map(_buildFeedItem).toList(),
              ),
            );
          },
        ),
        BlocBuilder<ArtistFeedEvent, ArtistFeedState>(
          bloc: artistFeedBloc,
          builder: (ctx, state) {
            if (state.isLoading) {
              return Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: _buildLoadingIndicator(),
              );
            } else
              return Container();
          },
        ),
      ],
    );
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
