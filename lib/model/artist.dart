import 'package:ikonfetemobile/model/model.dart';

class Artist extends Model<String> {
  String uid;
  String username;
  String name;
  String email;

  String facebookId;
  String twitterId;
  String spotifyUserId;
  String deezerUserId;

  DateTime dateCreated;
  DateTime dateUpdated;

  bool isVerified;
  DateTime dateVerified;
  bool isPendingVerification;
  String bio;
  String spotifyArtistId;
  String deezerArtistId;

  int feteScore = 0;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..uid = json["uid"]
      ..username = json["username"]
      ..name = json["name"]
      ..email = json["email"]
      ..facebookId = json["facebookId"]
      ..twitterId = json["twitterId"]
      ..spotifyUserId = json["spotifyUserId"]
      ..deezerUserId = json["deezerUserId"]
      ..feteScore = json["feteScore"] ?? 0
      ..isVerified = json["isVerified"] ?? false
      ..isPendingVerification = json["isPendingVerification"] ?? false
      ..bio = json["bio"]
      ..spotifyArtistId = json["spotifyArtistId"]
      ..deezerArtistId = json["deezerArtistId"];

    if (json.containsKey("dateCreated") &&
        json["dateCreated"] != null &&
        json["dateCreated"] > 0) {
      this.dateCreated =
          DateTime.fromMillisecondsSinceEpoch(json["dateCreated"] * 1000);
    }

    if (json.containsKey("dateUpdated") &&
        json["dateUpdated"] != null &&
        json["dateUpdated"] > 0) {
      this.dateUpdated =
          DateTime.fromMillisecondsSinceEpoch(json["dateUpdated"] * 1000);
    }

    if (json.containsKey("dateVerified") &&
        json["dateVerified"] != null &&
        json["dateVerified"] > 0) {
      final dateVerifiedNum = json["dateVerified"];
      this.dateVerified =
          DateTime.fromMillisecondsSinceEpoch(dateVerifiedNum * 1000);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      "uid": this.uid,
      "username": this.username,
      "name": this.name,
      "email": this.email,
      "facebookId": this.facebookId ?? "",
      "twitterId": this.twitterId ?? "",
      "spotifyUserId": this.spotifyUserId ?? "",
      "deezerUserId": this.deezerUserId ?? "",
      "feteScore": this.feteScore ?? 0,
      "isVerified": this.isVerified,
      "dateCreated": this.dateCreated == null
          ? null
          : this.dateCreated.millisecondsSinceEpoch / 1000,
      "dateUpdated": this.dateUpdated == null
          ? null
          : this.dateUpdated.millisecondsSinceEpoch / 1000,
      "dateVerified": this.dateVerified == null
          ? null
          : this.dateVerified.millisecondsSinceEpoch / 1000,
      "isPendingVerification": this.isVerified,
      "bio": this.bio,
      "spotifyArtistId": this.spotifyArtistId ?? "",
      "deezerArtistId": this.deezerArtistId ?? "",
    });
    return map;
  }
}
