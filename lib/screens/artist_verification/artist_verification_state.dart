import 'package:ikonfetemobile/types/types.dart';
import 'package:meta/meta.dart';

class ArtistVerificationState {
  final bool isLoading;
  final String facebookId;
  final String twitterId;
  final String twitterUsername;
  final String bio;
  final bool hasError;
  final String errorMessage;
  final Pair<bool, String> pendingVerificationResult;

  ArtistVerificationState({
    @required this.isLoading,
    @required this.facebookId,
    @required this.twitterId,
    @required this.twitterUsername,
    @required this.bio,
    @required this.hasError,
    @required this.errorMessage,
    @required this.pendingVerificationResult,
  });

  factory ArtistVerificationState.initial() {
    return ArtistVerificationState(
      isLoading: false,
      facebookId: null,
      twitterId: null,
      twitterUsername: null,
      bio: null,
      hasError: false,
      errorMessage: null,
      pendingVerificationResult: null,
    );
  }

  ArtistVerificationState withError(String errorMessage) {
    return copyWith(
        isLoading: false, hasError: true, errorMessage: errorMessage);
  }

  ArtistVerificationState copyWith({
    bool isLoading,
    String facebookId,
    String twitterId,
    String twitterUsername,
    String bio,
    bool hasError,
    String errorMessage,
    Pair<bool, String> pendingVerificationResult,
  }) {
    return ArtistVerificationState(
      isLoading: isLoading ?? this.isLoading,
      facebookId: facebookId ?? this.facebookId,
      twitterId: twitterId ?? this.twitterId,
      twitterUsername: twitterUsername ?? this.twitterUsername,
      bio: bio ?? this.bio,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      pendingVerificationResult:
          pendingVerificationResult ?? this.pendingVerificationResult,
    );
  }

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is ArtistVerificationState &&
      runtimeType == other.runtimeType &&
      isLoading == other.isLoading &&
      facebookId == other.facebookId &&
      twitterId == other.twitterId &&
      twitterUsername == other.twitterUsername &&
      bio == other.bio &&
      hasError == other.hasError &&
      errorMessage == other.errorMessage &&
      pendingVerificationResult == other.pendingVerificationResult;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      facebookId.hashCode ^
      twitterId.hashCode ^
      twitterUsername.hashCode ^
      bio.hashCode ^
      hasError.hashCode ^
      errorMessage.hashCode ^
      pendingVerificationResult.hashCode;
}
