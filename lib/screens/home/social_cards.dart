import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/model/SocialFeedItem.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/random_gradient_image.dart';
import 'package:timeago/timeago.dart' as timeago;

abstract class SocialCard extends StatelessWidget {
  final SocialFeedItem feedItem;
  final Artist artist;
  final double iconSize = 20.0;

  SocialCard(this.feedItem, this.artist);

  Icon get socialIcon;

  String get feedSource;

  Icon get favouriteIcon;

  List<Widget> get additionalActions;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 5.0,
              blurRadius: 20.0,
              offset: Offset(0.0, 10.0))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 10.0),
          buildHeader(),
          Container(
            padding:
                EdgeInsets.only(top: 5, bottom: 10.0, left: 0.0, right: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: buildTextContent(),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.0, right: 2.0),
                  child: buildImages(),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
//                    children: <Widget>[
////                      buildSocialIcon(),
//                      _buildLikes(),
//                      Expanded(child: Container()),
//                      _buildComments(),
//                    ],
                    children: <Widget>[]
                      ..add(_buildLikes())
                      ..add(SizedBox(width: 10.0))
                      ..addAll(additionalActions)
                      ..add(Expanded(child: Container()))
                      ..add(_buildComments()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    final now = DateTime.now();
    final postDate = feedItem.postedDate;
    final diff = now.difference(postDate);
    String postedFuzzyDate = timeago.format(now.subtract(diff));
    String profilePicUri = feedItem.profileImageUri ?? artist.profilePictureUrl;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
      leading: StringUtils.isNullOrEmpty(profilePicUri)
          ? RandomGradientImage()
          : RandomGradientImage(
              child: CircleAvatar(
                radius: 16.0,
                backgroundImage: NetworkImage(profilePicUri),
              ),
            ),
      title: Text(
        feedItem.name,
        style: TextStyle(
          fontSize: 16.0,
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: RichText(
        text: TextSpan(
          text: "$postedFuzzyDate via ",
          children: <TextSpan>[
            TextSpan(
              text: feedSource,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          style: TextStyle(
            fontSize: 13.0,
            color: Color(0xFF0707070),
          ),
        ),
      ),
      enabled: true,
    );
  }

  Widget buildTextContent() {
    return !StringUtils.isNullOrEmpty(feedItem.textContent)
        ? Text(
            feedItem.textContent,
            style: TextStyle(
              fontSize: 16.0,
              color: Color(0xFF0707070),
            ),
          )
        : Container();
  }

  Widget buildImages() {
    if (feedItem.images == null || feedItem.images.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: feedItem.images.length >= 3
          ? _buildThreeOrMoreImages()
          : (feedItem.images.length == 2
              ? _buildTwoImages()
              : _buildOneImage()),
    );
  }

  Widget _buildOneImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: 300.0),
        child: Image.network(
          feedItem.images[0].fullImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTwoImages() {
    return Container(
      constraints: BoxConstraints(maxHeight: 300.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0)),
              child: Container(
                height: double.infinity,
                child: Image.network(
                  feedItem.images[0].displayImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 5.0),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0)),
              child: Container(
                child: Image.network(
                  feedItem.images[1].displayImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreeOrMoreImages() {
    return Container(
      constraints: BoxConstraints(maxHeight: 300.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0)),
              child: Container(
                child: Image.network(
                  feedItem.images[0].displayImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 5.0),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Image.network(
                        feedItem.images[1].displayImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0),
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5.0),
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.asset(
                            feedItem.images[2].displayImage,
                            fit: BoxFit.cover,
                          ),
                          feedItem.images.length > 3
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: primaryColor.withOpacity(0.4),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.add, color: Colors.white),
                                      SizedBox(height: 5.0),
                                      Text("${3 - feedItem.images.length} more",
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSocialIcon() {
    return Opacity(
      child: socialIcon,
      opacity: 0.5,
    );
  }

  Widget _buildLikes() {
    return Row(
      children: <Widget>[
        favouriteIcon,
        SizedBox(width: 5),
        Text(
          StringUtils.abbreviateNumber(feedItem.numberOfLikes),
          style: TextStyle(
            fontSize: 18.0,
            fontFamily: "SanFranciscoDisplay",
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStackedImages() {
    //        Stack(
//          children: <Widget>[
//            Container(
//              transform: Matrix4.identity()..translate(0.0),
//              decoration: BoxDecoration(
//                shape: BoxShape.circle,
//                border: Border.all(color: Colors.white, width: 4.0),
//              ),
//              child: CircleAvatar(
//                  radius: 14.0,
//                  backgroundImage:
//                      AssetImage("assets/images/onboard_background1.png")),
//            ),
//            Container(
//              transform: Matrix4.identity()..translate(14.0),
//              decoration: BoxDecoration(
//                shape: BoxShape.circle,
//                border: Border.all(color: Colors.white, width: 4.0),
//              ),
//              child: CircleAvatar(
//                  radius: 14.0,
//                  backgroundImage:
//                      AssetImage("assets/images/onboard_background1.png")),
//            ),
//            Container(
//              transform: Matrix4.identity()..translate(28.0),
//              decoration: BoxDecoration(
//                shape: BoxShape.circle,
//                border: Border.all(color: Colors.white, width: 4.0),
//              ),
//              child: CircleAvatar(
//                  radius: 14.0,
//                  backgroundImage:
//                      AssetImage("assets/images/onboard_background1.png")),
//            ),
//          ],
//        ),
    return Container();
  }

  Widget _buildComments() {
    return Row(
      children: <Widget>[
        Icon(
          Icons.chat_bubble,
          color: Colors.black.withOpacity(0.2),
          size: 18,
        ),
        SizedBox(
          width: 5.0,
        ),
        Text(
          StringUtils.abbreviateNumber(feedItem.numberOfComments),
          style: TextStyle(
            fontSize: 18.0,
            fontFamily: "SanFranciscoDisplay",
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class TwitterSocialCard extends SocialCard {
  TwitterSocialCard(SocialFeedItem feedItem, Artist artist)
      : super(feedItem, artist);

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  Icon get socialIcon =>
      Icon(ThemifyIcons.twitter, color: twitterColor, size: iconSize);

  @override
  String get feedSource => "Twitter";

  @override
  Icon get favouriteIcon {
    final item = (feedItem as TwitterFeedItem);
    return Icon(
      item.favourited ? Icons.favorite : Icons.favorite_border,
      color: item.favourited ? primaryColor : Colors.black.withOpacity(0.4),
      size: iconSize,
    );
  }

  @override
  List<Widget> get additionalActions {
    return <Widget>[
      Row(
        children: <Widget>[
          Icon(LineAwesomeIcons.retweet, color: Colors.black.withOpacity(0.4)),
          SizedBox(width: 5),
          Text(
            "${(feedItem as TwitterFeedItem).retweetCount}",
            style: TextStyle(
              fontSize: 18.0,
              fontFamily: "SanFranciscoDisplay",
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
    ];
  }

  Widget buildTextContent() {
    if (StringUtils.isNullOrEmpty(feedItem.textContent)) {
      return Container();
    }

    List<TweetEntity> tweetEntities = [];
    final twitterFeedItem = (feedItem as TwitterFeedItem);
    final hashTags = twitterFeedItem.hashTags;
    final mentions = twitterFeedItem.userMentions;
    final urls = twitterFeedItem.urls;

    if (hashTags != null) tweetEntities.addAll(hashTags);
    if (mentions != null) tweetEntities.addAll(mentions);
//    if (urls != null) tweetEntities.addAll(urls); // TODO: strip urls from text
    if (tweetEntities.isEmpty) {
      return Text(
        feedItem.textContent,
        style: TextStyle(
          fontSize: 16.0,
          color: Color(0xFF0707070),
        ),
      );
    }

    Set<TweetEntity> sortedEntities =
        SplayTreeSet<TweetEntity>.from(tweetEntities);
    final textSpans = <TextSpan>[];
    final linkedTexts = <TwitterLinkedText>[];
    int start = 0;
    for (TweetEntity entity in sortedEntities) {
      String before = feedItem.textContent.substring(start, entity.startIndex);
      String link =
          feedItem.textContent.substring(entity.startIndex, entity.endIndex);
      start = entity.endIndex;
      linkedTexts.addAll([
        TwitterLinkedText(before, false),
        TwitterLinkedText(link, true),
      ]);
    }
    String rest =
        feedItem.textContent.substring(start, feedItem.textContent.length);
    linkedTexts.add(TwitterLinkedText(rest, false));

    for (TwitterLinkedText linkedText in linkedTexts) {
      final textSpan = TextSpan(
          text: linkedText.text,
          style: linkedText.isLinked
              ? TextStyle(color: Colors.blue)
              : TextStyle(color: Colors.black54));
      textSpans.add(textSpan);
    }

    final textWidget = RichText(text: TextSpan(text: "", children: textSpans));
    return textWidget;
  }
}

class TwitterLinkedText {
  String text;
  bool isLinked;

  TwitterLinkedText(this.text, this.isLinked);
}

class FacebookSocialCard extends SocialCard {
  FacebookSocialCard(SocialFeedItem feedItem, Artist artist)
      : super(feedItem, artist);

  @override
  Widget build(BuildContext context) {
    return super.build(context);
  }

  @override
  Icon get socialIcon =>
      Icon(ThemifyIcons.facebook, color: facebookColor, size: iconSize);

  @override
  String get feedSource => "Facebook";

  @override
  Icon get favouriteIcon {
    return Icon(
      Icons.favorite,
      color: primaryColor,
      size: iconSize,
    );
  }

  @override
  List<Widget> get additionalActions {
    return [];
  }
}
