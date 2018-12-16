import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/model/SocialFeedItem.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:meta/meta.dart';

class FeedApi extends Api {
  FeedApi(String apiBaseUrl) : super(apiBaseUrl);

  Future<List<SocialFeedItem>> loadFanFeed({
    @required String uid,
    @required String currentTeamID,
    @required String twitterConsumerKey,
    @required String twitterConsumerSecret,
    @required String twitterAccessToken,
    @required String twitterAccessSecret,
    @required String facebookAccessToken,
    int lastTweetId,
    String facebookPagingToken,
  }) async {
    var url = "$apiBaseUrl/fan_feed/$uid?currentTeamId=$currentTeamID";
    if (!StringUtils.isNullOrEmpty(facebookPagingToken)) {
      url += "&facebookPagingToken=$facebookPagingToken";
    }
    if (lastTweetId != null && lastTweetId != 0) {
      url += "&lastTweetId=$lastTweetId";
    }

    final headers = <String, String>{
      "TWITTER_CONSUMER_KEY": twitterConsumerKey,
      "TWITTER_CONSUMER_SECRET": twitterConsumerSecret,
      "TWITTER_ACCESS_TOKEN": twitterAccessToken,
      "TWITTER_ACCESS_SECRET": twitterAccessSecret,
      "FACEBOOK_ACCESS_TOKEN": facebookAccessToken,
    };

    try {
      http.Response response = await http.get(url, headers: headers);
      switch (response.statusCode) {
        case 200:
          Map bodyMap = json.decode(response.body);
          List<SocialFeedItem> items = _decodeFeedItems(bodyMap);
          return items;
        default:
          final apiErr = ApiError()..fromJson(json.decode(response.body));
          throw ApiException(apiErr.error);
      }
    } on PlatformException catch (e) {
      throw ApiException(e.message);
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  List<SocialFeedItem> _decodeFeedItems(Map bodyMap) {
    List<SocialFeedItem> items = <SocialFeedItem>[];

    List result = bodyMap["result"];
    for (var r in result) {
      SocialFeedItem item;
      switch (r["feedType"]) {
        case "facebook":
          item = FacebookFeedItem()..fromJson(r);
          break;
        case "twitter":
        default:
          item = TwitterFeedItem()..fromJson(r);
          break;
      }
      items.add(item);
    }

    return items;
  }
}
