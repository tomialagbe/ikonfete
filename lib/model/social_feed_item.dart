import 'package:ikonfetemobile/utils/strings.dart';

enum FeedItemType { facebook, twitter }

class SocialFeedImage {
  String displayImage;
  String fullImage;
}

class SocialFeedVideo {
  String displayImage;
  String videoUrl;
  int durationInMillis;
  String contentType;
  List<int> aspectRatio;
}

class SocialFeedGif {
  String displayImage;
  String gifImage;
  bool isImage;
  List<int> aspectRatio;
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

  List<SocialFeedVideo> get videos;

  List<SocialFeedGif> get gifs;

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

  @override
  List<SocialFeedVideo> get videos {
    return <SocialFeedVideo>[]; // TODO: implement this
  }

  @override
  List<SocialFeedGif> get gifs {
    return <SocialFeedGif>[];
  }
}

enum TweetMediaItemType { photo, video, animated_gif }
enum TwitterResize { crop, fit }

class TwitterFeedItem extends SocialFeedItem {
  String text;
  String realName;
  String screenName;
  String profileImageUrl;
  bool retweeted;
  int retweetCount;
  bool favourited;
  int favouriteCount;
  bool isRetweet;
  List<TweetMediaItem> media;
  List<TweetHashTag> hashTags;
  List<TweetUrl> urls;
  List<TweetUserMention> userMentions;
  RetweetInfo retweetInfo;
  QuotedTweet quotedTweet;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..text = json["text"]
      ..realName = json["name"]
      ..screenName = json["screenName"]
      ..profileImageUrl = json["profileImageUrl"]
      ..retweeted = json["retweeted"]
      ..retweetCount = json["retweetCount"]
      ..favourited = json["favourited"]
      ..favouriteCount = json["favouriteCount"]
      ..media = _parseMedia(json["media"] ?? null)
      ..hashTags = _parseHashTags(json["hashTags"] ?? null)
      ..urls = _parseUrls(json["urls"] ?? null)
      ..userMentions = _parseUserMentions(json["userMentions"] ?? null)
      ..isRetweet = json["isRetweet"]
      ..retweetInfo = json["retweetInfo"] == null
          ? null
          : RetweetInfo.fromJson(json["retweetInfo"])
      ..quotedTweet = json["quotedTweet"] == null
          ? null
          : QuotedTweet.fromJson(json["quotedTweet"]);

    // strip media urls from text
    var len = text.length;
    var shift = 0;
    for (TweetMediaItem mediaItem in media) {
      if (!StringUtils.isNullOrEmpty(this.text)) {
//        var start = 0;
//        var end =
//            shift > 0 ? mediaItem.startIndex - shift : mediaItem.startIndex;
//        if (start > len || end > len) continue;
//
//        final s1 = this.text.substring(start, end);
//
//        start = shift > 0 ? mediaItem.endIndex - shift : mediaItem.endIndex;
//        end = len;
//        if (start > len || end > len) continue;
//
//        final s2 = this.text.substring(start, end);
//
//        var newText = "$s1$s2";
//        shift = text.length - newText.length;
//
//        this.text = newText;
//        len = newText.length;

//        final runes = this.text.runes.toList();
//        final rem = runes.sublist(0, mediaItem.startIndex)
//          ..addAll(runes.sublist(mediaItem.endIndex, runes.length));
//        this.text = String.fromCharCodes(rem);
      }
    }

    _stripRetweetsFromText();
  }

  void _stripRetweetsFromText() {
    // strip retweet text (i.e in the format RT @screenName:) and the corresponding user mention
    if (this.text.startsWith("RT")) {
      final retweetMention = this.userMentions[0];
      int idx = retweetMention.endIndex + 1;
      this.userMentions.removeAt(0);
      this.text = this.text.substring(idx + 1);

      // adjust start and end indices in tweet entities to account for stripped text
      for (var mediaItem in media) {
        mediaItem.startIndex -= idx + 1;
        mediaItem.endIndex -= idx + 1;
      }
      for (var hashTag in hashTags) {
        hashTag.startIndex -= idx + 1;
        hashTag.endIndex -= idx + 1;
      }
      for (var url in urls) {
        url.startIndex -= idx + 1;
        url.endIndex -= idx + 1;
      }
      for (var mention in userMentions) {
        mention.startIndex -= idx + 1;
        mention.endIndex -= idx + 1;
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

    final imageItems =
        media.where((item) => item.type == TweetMediaItemType.photo);
    if (imageItems.isEmpty) return null;

    final feedImages = <SocialFeedImage>[]
      ..addAll(imageItems.map((imageItem) => SocialFeedImage()
        ..displayImage = imageItem.mediaUrl
        ..fullImage = imageItem.mediaUrl));
    return feedImages;
  }

  @override
  List<SocialFeedVideo> get videos {
    if (media == null) return null;

    final videoItems =
        media.where((item) => item.type == TweetMediaItemType.video);
    if (videoItems.isEmpty) return null;

    final feedVideos = <SocialFeedVideo>[]
      ..addAll(videoItems.map((videoItem) => SocialFeedVideo()
        ..durationInMillis = videoItem.videoInfo.durationMillis
        ..contentType = videoItem.videoInfo.contentType
        ..displayImage = videoItem.mediaUrl
        ..videoUrl = videoItem.videoInfo.videoUrl
        ..aspectRatio = videoItem.videoInfo.aspectRatio));
    return feedVideos;
  }

  @override
  List<SocialFeedGif> get gifs {
    if (media == null) return null;

    final gifItems =
        media.where((item) => item.type == TweetMediaItemType.animated_gif);
    if (gifItems.isEmpty) return null;

    final feedGifs = <SocialFeedGif>[]
      ..addAll(gifItems.map((gifItem) => SocialFeedGif()
        ..isImage = false
        ..displayImage = gifItem.mediaUrl
        ..gifImage = gifItem.videoInfo.videoUrl
        ..aspectRatio = gifItem.videoInfo.aspectRatio));
    return feedGifs;
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

class QuotedTweet {
  String screenName;
  String name;
  String text;

  QuotedTweet.fromJson(Map json) {
    this
      ..screenName = json["screenName"]
      ..name = json["name"]
      ..text = json["text"];
  }
}

class RetweetInfo {
  DateTime postedDate;
  String screenName;
  String name;
  String profilePictureUrl;

  RetweetInfo.fromJson(Map json) {
    this
      ..screenName = json["screenName"]
      ..name = json["name"]
      ..profilePictureUrl = json["profilePictureUrl"]
      ..postedDate =
          DateTime.fromMillisecondsSinceEpoch(json["postedDate"] * 1000);
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

    // handle videos
    this.videoInfo = type == TweetMediaItemType.video ||
            type == TweetMediaItemType.animated_gif
        ? _getVideoInfo(json["video_info"])
        : null;
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

  VideoInfo _getVideoInfo(Map videoInfoMap) {
    if (videoInfoMap == null) {
      return null;
    }

    final videoInfo = VideoInfo();
    List aspectRatio = videoInfoMap["aspect_ratio"];
    videoInfo.aspectRatio = <int>[aspectRatio[0], aspectRatio[1]];
    videoInfo.durationMillis = videoInfoMap["duration_millis"] ?? 0;

    List variants = videoInfoMap["variants"]; // TODO: handle better
    if (variants.isEmpty) {
      return null;
    }
    final largest = variants[0];
    videoInfo.contentType = largest["content_type"];
    videoInfo.videoUrl = largest["url"];
    return videoInfo;
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
  String videoUrl;
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
