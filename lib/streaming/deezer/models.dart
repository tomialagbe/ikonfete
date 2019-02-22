class DeezerInvalidSessionException implements Exception {
  final String code;
  final String message;

  DeezerInvalidSessionException(this.code, this.message);
}

enum DeezerUserStatus {
  Freemium,
  Premium,
  PremiumPlus,
}

enum DeezerPlayerState {
  Started,
  Initializing,
  Ready,
  Playing,
  Paused,
  PlaybackCompleted,
  WaitingForData,
  Stopped,
  Released,
}

enum DeezerBufferState { Started, Paused, Stopped }

class DeezerUser {
  int id;
  String gender;
  String email;
  String name;
  String firstName;
  String lastName;
  DeezerUserStatus status;
  String link;
  String smallImageUrl;
  String mediumImageUrl;
  String bigImageUrl;

  DeezerUser.fromMap(Map map) {
    this
      ..id = map["id"]
      ..gender = map["gender"]
      ..name = map["name"]
      ..firstName = map["firstName"]
      ..lastName = map["lastName"]
      ..status = _statusFromInt(map["status"])
      ..link = map["link"]
      ..smallImageUrl = map["smallImageUrl"]
      ..mediumImageUrl = map["mediumImageUrl"]
      ..bigImageUrl = map["bigImageUrl"];
  }

  DeezerUserStatus _statusFromInt(String status) {
    switch (status) {
      case "STATUS_FREEMIUM":
        return DeezerUserStatus.Freemium;
      case "STATUS_PREMIUM":
        return DeezerUserStatus.Premium;
      case "STATUS_PREMIUM_PLUS":
      default:
        return DeezerUserStatus.PremiumPlus;
    }
  }
}

class DeezerTrack {
  int id;

  // album info
  int albumId;
  String albumTitle;
  String albumLabel;
  String albumBigImageUrl;
  String albumMediumImageUrl;
  String albumSmallImageUrl;

  // artist info
  int artistId;
  String artistName;
  String artistBigImageUrl;
  String artistMediumImageUrl;
  String artistSmallImageUrl;

  Duration duration; // in ms
  String link;
  DateTime releaseDate;
  String shortTitle;
  String title;

  DeezerTrack.fromMap(Map map) {
    this
      ..id = map["id"] is String ? int.parse(map["id"]) : map["id"]
      ..albumId =
          map["albumId"] is String ? int.parse(map["albumId"]) : map["albumId"]
      ..albumTitle = map["albumTitle"]
      ..albumLabel = map["albumLabel"]
      ..albumBigImageUrl = map["albumBigImageUrl"]
      ..albumMediumImageUrl = map["albumMediumImageUrl"]
      ..albumSmallImageUrl = map["albumSmallImageUrl"]
      ..artistId = map["artistId"] is String
          ? int.parse(map["artistId"])
          : map["artistId"]
      ..artistName = map["artistName"]
      ..artistBigImageUrl = map["artistBigImageUrl"]
      ..artistMediumImageUrl = map["artistMediumImageUrl"]
      ..artistSmallImageUrl = map["artistSmallImageUrl"]
      ..duration = Duration(seconds: map["duration"])
      ..link = map["link"]
      ..releaseDate =
          new DateTime.fromMillisecondsSinceEpoch(map["releaseDate"])
      ..shortTitle = map["shortTitle"]
      ..title = map["title"];
  }
}

class DeezerPlayerEvent {
  DeezerPlayerState state;
  int timePosition;

  DeezerPlayerEvent(this.state, this.timePosition);

  DeezerPlayerEvent.fromMap(Map map) {
    this
      ..timePosition = map["timePosition"]
      ..state = _stringToPlayerState(map["state"]);
  }

  DeezerPlayerState _stringToPlayerState(String s) {
    switch (s) {
      case "STARTED":
        return DeezerPlayerState.Started;
      case "INITIALIZING":
        return DeezerPlayerState.Initializing;
      case "READY":
        return DeezerPlayerState.Ready;
      case "PLAYING":
        return DeezerPlayerState.Playing;
      case "PAUSED":
        return DeezerPlayerState.Paused;
      case "PLAYBACK_COMPLETED":
        return DeezerPlayerState.PlaybackCompleted;
      case "WAITING_FOR_DATA":
        return DeezerPlayerState.WaitingForData;
      case "Stopped":
        return DeezerPlayerState.Stopped;
      case "Released":
      default:
        return DeezerPlayerState.Released;
    }
  }
}

class DeezerBufferEvent {
  DeezerBufferState state;
  double bufferPercent;

  DeezerBufferEvent(this.state, this.bufferPercent);

  DeezerBufferEvent.fromMap(Map map) {
    this
      ..state = _stringToBufferSate(map["state"])
      ..bufferPercent = map["bufferPercent"];
  }

  DeezerBufferState _stringToBufferSate(String s) {
    switch (s) {
      case "STARTED":
        return DeezerBufferState.Started;
        break;
      case "PAUSED":
        return DeezerBufferState.Paused;
        break;
      case "STOPPED":
      default:
        return DeezerBufferState.Stopped;
        break;
    }
  }
}
