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
      ..bio = json["bio"]
      ..spotifyArtistId = json["spotifyArtistId"]
      ..deezerArtistId = json["deezerArtistId"];
  }

  @override
  Map toJson() {
    final map = super.toJson();
    map.addAll({
      "uid": this.uid,
      "username": this.username,
      "email": this.email,
      "name": this.name,
//      "phoneNumber": this.phoneNumber ?? "",
//      "isActivated": this.isActivated,
//      "profilePictureUrl": this.profilePictureUrl ?? "",
      "facebookId": this.facebookId ?? "",
      "twitterId": this.twitterId ?? "",
      "spotifyUserId": this.spotifyUserId ?? "",
      "deezerUserId": this.deezerUserId ?? "",
      "feteScore": this.feteScore ?? "",
      "isVerified": this.isVerified,
      "bio": this.bio,
      "spotifyArtistId": this.spotifyArtistId ?? "",
      "deezerArtistId": this.deezerArtistId ?? "",
    });
    return map;
  }
}
//typedef Team TeamLoader(String teamId);

//class Fan extends User {
//  Team team;
//  TeamLoader teamLoader;
//
//  Fan({
//    this.teamLoader,
//  });
//
//  @override
//  void fromJson(Map json) {
//    super.fromJson(json);
//    this..team = teamLoader(json["teamId"]);
//  }
//
//  @override
//  Map toJson() {
//    Map json = super.toJson();
//    json.addAll({
////      "teamId": this.team.id,
//    });
//    return json;
//  }
//}
