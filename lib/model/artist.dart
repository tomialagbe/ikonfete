import 'package:ikonfetemobile/model/model.dart';

class Artist extends Model<String> {
  String uid;
  String username;
  String email;
  String name;

//  String phoneNumber;
//  bool isActivated = false;
//  String profilePictureUrl;

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
      ..email = json["email"]
      ..name = json["name"]
      ..facebookId = json["facebookId"]
      ..twitterId = json["twitterId"]
      ..spotifyUserId = json["spotifyUserId"]
      ..deezerUserId = json["deezerUserId"]
      ..feteScore = json["feteScore"]
      ..isVerified = json["isVerified"]
      ..isPendingVerification = json["isPendingVerification"]
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
  Map toJson() {
    final map = super.toJson();
    map.addAll({
      "uid": this.uid,
      "username": this.username,
      "email": this.email,
      "name": this.name,
      "facebookId": this.facebookId ?? "",
      "twitterId": this.twitterId ?? "",
      "spotifyUserId": this.spotifyUserId ?? "",
      "deezerUserId": this.deezerUserId ?? "",
      "feteScore": this.feteScore ?? "",
      "isVerified": this.isVerified,
      "dateVerified": this.dateVerified.millisecondsSinceEpoch / 1000,
      "isPendingVerification": this.isVerified,
      "bio": this.bio,
      "spotifyArtistId": this.spotifyArtistId ?? "",
      "deezerArtistId": this.deezerArtistId ?? "",
    });
    return map;
  }
}
