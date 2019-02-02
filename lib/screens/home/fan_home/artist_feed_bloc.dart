import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:ikonfetemobile/api/feed.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/social_feed_item.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:meta/meta.dart';

abstract class ArtistFeedEvent {}

class LoadFeed extends ArtistFeedEvent {
  final bool refresh;

  LoadFeed({this.refresh: false});
}

class _LoadFeed extends ArtistFeedEvent {
  final bool refresh;

  _LoadFeed({this.refresh: false});
}

class ArtistFeedState {
  final bool isLoading;
  final bool hasReachedMax;
  final Set<SocialFeedItem> feedItems;
  final String facebookPagingToken;
  final int lastTweetId;

  ArtistFeedState({
    this.isLoading,
    this.hasReachedMax,
    this.feedItems,
    this.facebookPagingToken,
    this.lastTweetId,
  });

  factory ArtistFeedState.initial() {
    return ArtistFeedState(
      isLoading: false,
      feedItems: SplayTreeSet<SocialFeedItem>(),
      facebookPagingToken: null,
      lastTweetId: 0,
    );
  }

  ArtistFeedState copyWith({
    bool isLoading,
    bool hasReachedMax,
    Set<SocialFeedItem> feedItems,
    String facebookPagingToken,
    int lastTweetId,
  }) {
    return ArtistFeedState(
      isLoading: isLoading ?? this.isLoading,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      feedItems: feedItems ?? this.feedItems,
      facebookPagingToken: facebookPagingToken ?? this.facebookPagingToken,
      lastTweetId: lastTweetId ?? this.lastTweetId,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is ArtistFeedState &&
      this.runtimeType == other.runtimeType &&
      isLoading == other.isLoading &&
      hasReachedMax == other.hasReachedMax &&
      feedItems == other.feedItems &&
      facebookPagingToken == other.facebookPagingToken &&
      lastTweetId == other.lastTweetId;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      hasReachedMax.hashCode ^
      feedItems.hashCode ^
      facebookPagingToken.hashCode ^
      lastTweetId.hashCode;
}

class ArtistFeedBloc extends Bloc<ArtistFeedEvent, ArtistFeedState> {
  final AppConfig appConfig;
  final Artist artist;
  final String fanUid;
  final String currentTeamId;

  ArtistFeedBloc({
    @required this.appConfig,
    @required this.artist,
    @required this.fanUid,
    @required this.currentTeamId,
  });

  @override
  ArtistFeedState get initialState => ArtistFeedState.initial();

  @override
  void onTransition(Transition<ArtistFeedEvent, ArtistFeedState> transition) {
    super.onTransition(transition);
    final event = transition.event;
    if (event is LoadFeed) {
      dispatch(_LoadFeed(refresh: event.refresh));
    }
  }

  @override
  Stream<ArtistFeedState> mapEventToState(
      ArtistFeedState state, ArtistFeedEvent event) async* {
    if (event is LoadFeed) {
      yield state.copyWith(isLoading: true);
    }

    if (event is _LoadFeed) {
      final feedItems = event.refresh
          ? await loadFeed(null, 0)
          : await loadFeed(state.facebookPagingToken, state.lastTweetId);
      final items = state.feedItems.toList() + feedItems;

      final fbi = items?.lastWhere(
        (item) {
          return (item is FacebookFeedItem) &&
              !StringUtils.isNullOrEmpty(item.pagingToken);
        },
        orElse: () => null,
      );
      final fbPagingToken =
          fbi != null ? (fbi as FacebookFeedItem).pagingToken : "";

      final twid = items
          .lastWhere((item) => item is TwitterFeedItem, orElse: () => null)
          ?.id;
      final lastTweetId = twid != null ? int.parse(twid) : -1;

      yield state.copyWith(
        feedItems: SplayTreeSet.from(items.toList()),
        isLoading: false,
        lastTweetId: lastTweetId,
        facebookPagingToken: fbPagingToken,
      );
    }
  }

  Future<List<SocialFeedItem>> loadFeed(
      String facebookPagingToken, int lastTweetId) async {
    final fbAuth = FacebookAuth();
    final facebookAccessToken = (await fbAuth.facebookAccessToken());
    final feedApi = FeedApi(appConfig.serverBaseUrl);
    List<SocialFeedItem> items = await feedApi.loadFanFeed(
      uid: fanUid,
      currentTeamID: currentTeamId,
      twitterConsumerKey: appConfig.twitterConfig.consumerKey,
      twitterConsumerSecret: appConfig.twitterConfig.consumerSecret,
      twitterAccessToken: appConfig.twitterConfig.accessToken,
      twitterAccessSecret: appConfig.twitterConfig.accessTokenSecret,
      facebookAccessToken: facebookAccessToken,
      facebookPagingToken: facebookPagingToken,
      lastTweetId: lastTweetId,
    );
    return items;
  }
}
