import 'package:ikonfetemobile/model/model.dart';

class Artist extends Model<String> {
  String uid;
  String username;
  String name;

  String facebookId;
  String twitterId;
  String spotifyUserId;
  String deezerUserId;

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

    if (json.containsKey("dateVerified") && json["dateVerified"] != null) {
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
      "facebookId": this.facebookId ?? "",
      "twitterId": this.twitterId ?? "",
      "spotifyUserId": this.spotifyUserId ?? "",
      "deezerUserId": this.deezerUserId ?? "",
      "feteScore": this.feteScore ?? 0,
      "isVerified": this.isVerified,
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
