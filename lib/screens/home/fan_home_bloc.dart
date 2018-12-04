import 'dart:async';

import 'package:ikonfetemobile/api/api.dart';
import 'package:ikonfetemobile/api/artist.dart';
import 'package:ikonfetemobile/api/feed.dart';
import 'package:ikonfetemobile/api/teams.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/SocialFeedItem.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/utils/facebook_auth.dart';
import 'package:meta/meta.dart';

class FanHomeBloc extends BlocBase {
  final AppConfig appConfig;

  StreamController<List<SocialFeedItem>> _socialFeedItemStream =
      StreamController();

  StreamController<SocialFeedLoadError> _socialFeedLoadErrorController =
      StreamController();

  StreamController<FacebookAuthResult> _facebookAuthResultController =
      StreamController();

  StreamController<Artist> _loadArtistResultStream = StreamController();

  Stream<List<SocialFeedItem>> get socialFeedItems =>
      _socialFeedItemStream.stream;

  Stream<SocialFeedLoadError> get socialFeedLoadErrors =>
      _socialFeedLoadErrorController.stream;

  Stream<FacebookAuthResult> get facebookAuthResults =>
      _facebookAuthResultController.stream;

  Stream<Artist> get artistResult => _loadArtistResultStream.stream;

  bool isLoading = false;

  FanHomeBloc({
    this.appConfig,
  });

  @override
  void dispose() {
    _socialFeedItemStream.close();
    _socialFeedLoadErrorController.close();
    _facebookAuthResultController.close();
  }

  void loadFollowedArtist({@required String currentTeamId}) async {
    isLoading = true;
    final teamApi = TeamApi(appConfig.serverBaseUrl);
    final artistApi = ArtistApi(appConfig.serverBaseUrl);
    try {
      final team = await teamApi.getTeamByID(currentTeamId);
      if (team == null) {
        throw ApiException("Artist team not found");
      }
      final artist = await artistApi.findByUID(team.artistUid);
      if (artist == null) {
        throw ApiException("Artist not found");
      }
      isLoading = false;
      _loadArtistResultStream.add(artist);
    } on ApiException catch (e) {
      isLoading = false;
      _loadArtistResultStream.addError(e.message);
    } on Exception catch (e) {
      isLoading = false;
      _loadArtistResultStream.addError(e.toString());
    }
  }

  void loadSocialFeed({
    @required String uid,
    @required String currentTeamId,
    String facebookPagingToken,
    int lastTweetId,
  }) async {
    // check facebook login
    isLoading = true;
    final fbAuth = FacebookAuth();
    if (!(await fbAuth.isLoggedIn())) {
      _socialFeedLoadErrorController.add(SocialFeedLoadError(
          SocialFeedLoadErrorType.facebookAuth, "Invalid facebook session"));
      return;
    }

    try {
      final facebookAccessToken = (await fbAuth.facebookAccessToken());
      final feedApi = FeedApi(appConfig.serverBaseUrl);
      List<SocialFeedItem> items = await feedApi.loadFanFeed(
        uid: uid,
        currentTeamID: currentTeamId,
        twitterConsumerKey: appConfig.twitterConfig.consumerKey,
        twitterConsumerSecret: appConfig.twitterConfig.consumerSecret,
        twitterAccessToken: appConfig.twitterConfig.accessToken,
        twitterAccessSecret: appConfig.twitterConfig.accessTokenSecret,
        facebookAccessToken: facebookAccessToken,
        facebookPagingToken: facebookPagingToken,
        lastTweetId: lastTweetId,
      );
      isLoading = false;
      _socialFeedItemStream.add(items);
    } on ApiException catch (e) {
      isLoading = false;
      _socialFeedItemStream.addError(e.message);
    } on Exception catch (e) {
      isLoading = false;
      _socialFeedItemStream.addError(e.toString());
    }
  }

  void facebookAuth() async {
    isLoading = true;
    final fbAuth = FacebookAuth();
    final fbAuthResult = await fbAuth.facebookAuth();
    isLoading = true;
    _facebookAuthResultController.add(fbAuthResult);
  }
}

enum SocialFeedLoadErrorType { network, facebookAuth }

class SocialFeedLoadError {
  String message;
  SocialFeedLoadErrorType type;

  SocialFeedLoadError(this.type, this.message);
}
