import 'package:ikonfetemobile/utils/strings.dart';

enum FeedItemType { facebook, twitter }

class SocialFeedImage {
  String displayImage;
  String fullImage;
}

abstract class SocialFeedItem implements Comparable<SocialFeedItem> {
  String id;
  FeedItemType type;
  DateTime postedDate;

  void fromJson(Map json) {
    this
      ..id = json["id"]
      ..type = json["feedType"] == "facebook"
          ? FeedItemType.facebook
          : FeedItemType.twitter
      ..postedDate =
          DateTime.fromMillisecondsSinceEpoch(json["postedDate"] * 1000);
  }

  String get name;

  String get profileImageUri;

  int get numberOfLikes;

  int get numberOfComments;

  String get textContent;

  List<SocialFeedImage> get images;

  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(other) {
    if (!(other is SocialFeedItem)) {
      return false;
    }
    return other.hashCode != hashCode;
  }

  @override
  int compareTo(SocialFeedItem other) {
    return other.postedDate.compareTo(postedDate);
  }
}

enum FacebookPostType { photo, status, link, video, offer }

FacebookPostType facebookPostTypeFromString(String str) {
  switch (str) {
    case "photo":
      return FacebookPostType.photo;
    case "status":
      return FacebookPostType.status;
    case "link":
      return FacebookPostType.link;
    case "video":
      return FacebookPostType.video;
    case "offer":
      return FacebookPostType.offer;
    default:
      return FacebookPostType.status;
  }
}

class FacebookFeedItem extends SocialFeedItem {
  String message;
  FacebookPostType postType;
  String picture;
  String fullPicture;
  String caption;
  String description;
  String link;
  String linkName;
  String authorName;
  String pagingToken;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..message = json["message"]
      ..postType = facebookPostTypeFromString(json["type"])
      ..picture = json["picture"]
      ..fullPicture = json["fullPicture"]
      ..caption = json["caption"]
      ..description = json["description"]
      ..link = json["link"]
      ..linkName = json["linkName"]
      ..authorName = json["authorName"]
      ..pagingToken = json["pagingToken"];
  }

  @override
  String get name => authorName;

  @override
  String get profileImageUri => null;

  @override
  int get numberOfComments => 0;

  @override
  int get numberOfLikes => 0;

  @override
  String get textContent => message;

  @override
  List<SocialFeedImage> get images {
    if (StringUtils.isNullOrEmpty(picture) &&
        StringUtils.isNullOrEmpty(fullPicture)) {
      return null;
    } else {
      return <SocialFeedImage>[
        SocialFeedImage()
          ..displayImage = picture
          ..fullImage = fullPicture,
      ];
    }
  }
}

enum TweetMediaItemType { photo, video, animated_gif }
enum TwitterResize { crop, fit }

class TwitterFeedItem extends SocialFeedItem {
  String text;
  String screenName;
  String profileImageUrl;
  bool retweeted;
  int retweetCount;
  bool favourited;
  int favouriteCount;
  List<TweetMediaItem> media;
  List<TweetHashTag> hashTags;
  List<TweetUrl> urls;
  List<TweetUserMention> userMentions;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..text = json["text"]
      ..screenName = json["screenName"]
      ..profileImageUrl = json["profileImageUrl"]
      ..retweeted = json["retweeted"]
      ..retweetCount = json["retweetCount"]
      ..favourited = json["favourited"]
      ..favouriteCount = json["favouriteCount"]
      ..media = _parseMedia(json["media"] ?? null)
      ..hashTags = _parseHashTags(json["hashTags"] ?? null)
      ..urls = _parseUrls(json["urls"] ?? null)
      ..userMentions = _parseUserMentions(json["userMentions"] ?? null);

    // strip media urls from text
    for (TweetMediaItem mediaItem in media) {
      if (mediaItem.type == TweetMediaItemType.photo ||
          mediaItem.type == TweetMediaItemType.animated_gif) {
        this.text = this.text.substring(0, mediaItem.startIndex);
      }
    }
  }

  @override
  String get name => "@$screenName";

  @override
  String get profileImageUri => profileImageUrl;

  @override
  int get numberOfComments => 0;

  @override
  int get numberOfLikes => favouriteCount;

  @override
  String get textContent => text;

  @override
  List<SocialFeedImage> get images {
    if (media == null) return null;

    final imageItems = media.where((item) =>
        item.type == TweetMediaItemType.photo ||
        item.type == TweetMediaItemType.animated_gif);
    if (imageItems.isEmpty) return null;

    final feedImages = <SocialFeedImage>[]
      ..addAll(imageItems.map((imageItem) => SocialFeedImage()
        ..displayImage = imageItem.mediaUrl
        ..fullImage = imageItem.mediaUrl));
    return feedImages;
  }

  List<TweetMediaItem> _parseMedia(List json) {
    List<TweetMediaItem> media = <TweetMediaItem>[];
    if (json != null) {
      for (var j in json) {
        final mediaItem = TweetMediaItem.fromJson(j);
        media.add(mediaItem);
      }
    }
    return media;
  }

  List<TweetHashTag> _parseHashTags(List json) {
    List<TweetHashTag> hashTags = <TweetHashTag>[];
    if (json != null) {
      for (var j in json) {
        final hashTag = TweetHashTag.fromJson(j);
        hashTags.add(hashTag);
      }
    }
    return hashTags;
  }

  List<TweetUrl> _parseUrls(List urlJson) {
    List<TweetUrl> urls = <TweetUrl>[];
    if (urlJson != null) {
      for (var uj in urlJson) {
        final tweetUrl = TweetUrl.fromJson(uj);
        urls.add(tweetUrl);
      }
    }
    return urls;
  }

  List<TweetUserMention> _parseUserMentions(List json) {
    List<TweetUserMention> mentions = <TweetUserMention>[];
    if (json != null) {
      for (var j in json) {
        final mention = TweetUserMention.fromJson(j);
        mentions.add(mention);
      }
    }
    return mentions;
  }
}

class TweetMediaItem {
  int startIndex;
  int endIndex;
  String displayUrl;
  String expandedUrl;
  String url;
  int id;
  String mediaUrl;
  String mediaUrlHttps;
  TweetMediaItemType type;
  MediaSizes sizes;
  VideoInfo videoInfo;

  TweetMediaItem.fromJson(Map json) {
    final List indices = json["indices"];
    this
      ..startIndex = indices[0]
      ..endIndex = indices[1]
      ..displayUrl = json["display_url"]
      ..expandedUrl = json["expanded_url"]
      ..url = json["url"]
      ..id = json["id"]
      ..mediaUrl = json["media_url"]
      ..type = _getTwitterMediaItemType(json["type"]);
    // TODO: handle videos
  }

  TweetMediaItemType _getTwitterMediaItemType(String str) {
    switch (str) {
      case "photo":
        return TweetMediaItemType.photo;
      case "video":
        return TweetMediaItemType.video;
      case "animated_gif":
        return TweetMediaItemType.animated_gif;
      default:
        return TweetMediaItemType.photo;
    }
  }
}

class MediaSizes {
  MediaSize thumb;
  MediaSize large;
  MediaSize medium;
  MediaSize small;
}

class MediaSize {
  int height;
  int width;
  TwitterResize resize;
}

class VideoInfo {
  String contentType;
  List<int> aspectRatio;
  int durationMillis;
  List<VideoVariant> variants;
}

class VideoVariant {
  String contentType;
  int bitrate;
  String url;
}

abstract class TweetEntity implements Comparable<TweetEntity> {
  int startIndex;
  int endIndex;

  void fromJson(Map json) {
    this
      ..startIndex = json["startIndex"]
      ..endIndex = json["endIndex"];
  }

  int compareTo(TweetEntity other) => startIndex.compareTo(other.startIndex);
}

class TweetHashTag extends TweetEntity {
  String text;

  TweetHashTag.fromJson(Map json) {
    super.fromJson(json);
    this..text = json["text"];
  }
}

class TweetUrl extends TweetEntity {
  String url;
  String displayUrl;
  String expandedUrl;

  TweetUrl.fromJson(Map json) {
    super.fromJson(json);
    this
      ..url = json["url"]
      ..displayUrl = json["displayUrl"]
      ..expandedUrl = json["expandedUrl"];
  }
}

class TweetUserMention extends TweetEntity {
  int userId;
  String name;
  String screenName;

  TweetUserMention.fromJson(Map json) {
    super.fromJson(json);
    this
      ..userId = json["id"]
      ..name = json["name"]
      ..screenName = json["screenName"];
  }
}
