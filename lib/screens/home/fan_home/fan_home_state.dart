import 'package:ikonfetemobile/model/artist.dart';

enum FanHomeActiveTab { ArtistFeed, TeamFeed, Leaderboard }

class FanHomeState {
  FanHomeActiveTab activeTab;
  bool isArtistLoading;
  bool isArtistLoaded;
  Artist artist;
  bool loadArtistFailed;
  String loadArtistError;
  bool isFacebookAuthorized;
  String facebookAuthError;
  String facebookAccessToken;

  FanHomeState({
    this.activeTab,
    this.isArtistLoaded,
    this.isArtistLoading,
    this.artist,
    this.loadArtistFailed,
    this.loadArtistError,
    this.isFacebookAuthorized,
    this.facebookAuthError,
    this.facebookAccessToken,
  });

  factory FanHomeState.initial() {
    return FanHomeState(
      activeTab: FanHomeActiveTab.ArtistFeed,
      isArtistLoading: true,
      isArtistLoaded: false,
      artist: null,
      loadArtistFailed: false,
      loadArtistError: null,
      isFacebookAuthorized: true,
      facebookAuthError: null,
      facebookAccessToken: null,
    );
  }

  FanHomeState copyWith({
    FanHomeActiveTab activeTab,
    bool isArtistLoading,
    bool isArtistLoaded,
    Artist artist,
    bool loadArtistFailed,
    String loadArtistError,
    bool isFacebookAuthorized,
    String facebookAuthError,
    String facebookAccessToken,
  }) {
    return FanHomeState(
      activeTab: activeTab ?? this.activeTab,
      isArtistLoading: isArtistLoading ?? this.isArtistLoading,
      isArtistLoaded: isArtistLoaded ?? this.isArtistLoaded,
      artist: artist ?? this.artist,
      loadArtistFailed: loadArtistFailed ?? this.loadArtistFailed,
      loadArtistError: loadArtistError ?? this.loadArtistError,
      isFacebookAuthorized: isFacebookAuthorized ?? this.isFacebookAuthorized,
      facebookAuthError: facebookAuthError ?? this.facebookAuthError,
      facebookAccessToken: facebookAccessToken ?? this.facebookAccessToken,
    );
  }

  @override
  String toString() =>
      'FanHomeState { activeTab: $activeTab, isArtistLoaded: $isArtistLoaded,'
      ' isArtistLoading: $isArtistLoading artist: ${artist?.toString() ?? ''},'
      ' loadArtistFailed: $loadArtistFailed, '
      'loadArtistError: ${loadArtistError ?? ''}, isFacebookAuthorized: $isFacebookAuthorized, '
      'facebookAuthError: ${facebookAuthError ?? ''}, facebookAccessToken: $facebookAccessToken,  }';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FanHomeState &&
          runtimeType == other.runtimeType &&
          activeTab == other.activeTab &&
          isArtistLoading == other.isArtistLoading &&
          isArtistLoaded == other.isArtistLoaded &&
          artist == other.artist &&
          loadArtistFailed == other.loadArtistFailed &&
          loadArtistError == other.loadArtistError &&
          isFacebookAuthorized == other.isFacebookAuthorized &&
          facebookAuthError == other.facebookAuthError &&
          facebookAccessToken == other.facebookAccessToken;

  @override
  int get hashCode =>
      activeTab.hashCode ^
      isArtistLoading.hashCode ^
      isArtistLoaded.hashCode ^
      artist.hashCode ^
      loadArtistFailed.hashCode ^
      loadArtistError.hashCode ^
      isFacebookAuthorized.hashCode ^
      facebookAuthError.hashCode ^
      facebookAccessToken.hashCode;
}
