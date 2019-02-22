import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/social_feed_item.dart';
import 'package:ikonfetemobile/screens/home/widgets/social_card_image.dart';
import 'package:ikonfetemobile/screens/home/widgets/social_card_video.dart';
import 'package:ikonfetemobile/screens/home/widgets/twitter_gif.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/random_gradient_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:utf/utf.dart';

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
                  child: buildImages(context),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.0, right: 2.0),
                  child: buildGifs(context),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 2.0, right: 2.0),
                  child: buildVideo(context),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
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

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
      leading: StringUtils.isNullOrEmpty(profilePicture)
          ? RandomGradientImage()
          : RandomGradientImage(
              child: CircleAvatar(
                radius: 16.0,
                backgroundImage: NetworkImage(profilePicture),
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

  String get profilePicture =>
      feedItem.profileImageUri ?? artist.profilePictureUrl;

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

  Widget buildImages(BuildContext context) {
    if (feedItem.images == null || feedItem.images.isEmpty) {
      return Container();
    }

    return SocialCardImage(feedItem: feedItem);
  }

  Widget buildVideo(BuildContext context) {
    if (feedItem.videos == null || feedItem.videos.isEmpty) {
      return Container();
    }
    return SocialCardVideo(
      videoUrl: feedItem.videos[0].videoUrl,
      placeHolderUrl: feedItem.videos[0].displayImage,
      videoDuration:
          Duration(milliseconds: feedItem.videos[0].durationInMillis),
      aspectRatio:
          feedItem.videos[0].aspectRatio[0] / feedItem.videos[0].aspectRatio[1],
    );
  }

  Widget buildGifs(BuildContext context);

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

  @override
  String get profilePicture {
    final twitterFeedItem = feedItem as TwitterFeedItem;
    if (twitterFeedItem.isRetweet) {
      return twitterFeedItem.retweetInfo.profilePictureUrl;
    } else {
      return feedItem.profileImageUri ?? artist.profilePictureUrl;
    }
  }

  @override
  Widget buildHeader() {
    final now = DateTime.now();
    final postDate = feedItem.postedDate;
    final diff = now.difference(postDate);
    String postedFuzzyDate = timeago.format(now.subtract(diff));

    final twitterFeedItem = feedItem as TwitterFeedItem;
    String screenName = twitterFeedItem.isRetweet
        ? twitterFeedItem.retweetInfo.screenName
        : twitterFeedItem.screenName;
    String name = twitterFeedItem.isRetweet
        ? twitterFeedItem.retweetInfo.name
        : twitterFeedItem.realName;

    final retweetIndicator = twitterFeedItem.isRetweet
        ? Row(
            children: <Widget>[
              SizedBox(width: 64),
              Icon(
                LineAwesomeIcons.retweet,
                size: 24,
                color: primaryColor.withOpacity(0.5),
              ),
              SizedBox(width: 10),
              Text(
                "${twitterFeedItem.realName} Retweeted",
                style: TextStyle(color: Color(0xFF0707070)),
              ),
            ],
          )
        : Container();

    return Column(
      children: <Widget>[
        retweetIndicator,
        ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
          leading: StringUtils.isNullOrEmpty(profilePicture)
              ? RandomGradientImage()
              : RandomGradientImage(
                  child: CircleAvatar(
                    radius: 16.0,
                    backgroundImage: NetworkImage(profilePicture),
                  ),
                ),
          title: RichText(
            text: TextSpan(
              text: name,
              style: TextStyle(
                fontSize: 16.0,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: "  @$screenName",
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),
                ),
              ],
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
        ),
      ],
    );
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
    if (urls != null) tweetEntities.addAll(urls);
    String decoded = decodeUtf16(feedItem.textContent.codeUnits);
    if (decoded.trim().isEmpty) {
      // Skip displaying Malformed UTF-16 characters
      return Container();
    }

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
    final runes = feedItem.textContent.runes.toList();
    for (TweetEntity entity in sortedEntities) {
      var s = runes.sublist(start, entity.startIndex);
      String before = s.isNotEmpty ? String.fromCharCodes(s) : "";

      s = runes.sublist(entity.startIndex, entity.endIndex);
      String link = s.isNotEmpty ? String.fromCharCodes(s) : "";

      start = entity.endIndex;
      linkedTexts.addAll([
        TwitterLinkedText(before, false),
        TwitterLinkedText(link, true),
      ]);
    }

    var s = runes.sublist(start, runes.length);
    String rest = s.isNotEmpty ? String.fromCharCodes(s) : "";
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

  @override
  Widget buildGifs(BuildContext context) {
    if (feedItem.gifs == null || feedItem.gifs.isEmpty) {
      return Container();
    }

    return TwitterGif(
      placeHolderUrl: feedItem.gifs[0].displayImage,
      gifUrl: feedItem.gifs[0].gifImage,
      aspectRatio:
          (feedItem.gifs[0].aspectRatio[0] / feedItem.gifs[0].aspectRatio[1])
              .toDouble(),
    );
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
  Widget buildGifs(BuildContext context) {
    return Container();
  }

  @override
  List<Widget> get additionalActions {
    return [];
  }
}
