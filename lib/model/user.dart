import 'package:ikonfetemobile/model/model.dart';
import 'package:ikonfetemobile/model/team.dart';

class User extends Model<String> {
  String uid;
  String username;
  String email;
  String name;
  String phoneNumber;
  bool isActivated = false;
  String profilePictureUrl;

  String facebookId;
  String twitterId;
  String spotifyUserId;
  String deezerUserId;

  int feteScore = 0;

  @override
  void fromJson(Map json) {
    this
      ..uid = json["uid"]
      ..username = json["username"]
      ..email = json["email"]
      ..name = json["name"]
      ..phoneNumber = json["phoneNumber"]
      ..isActivated = json["isActviated"]
      ..profilePictureUrl = json["profilePictureUrl"]
      ..facebookId = json["facebookId"]
      ..twitterId = json["twitterId"]
      ..spotifyUserId = json["spotifyUserId"]
      ..deezerUserId = json["deezerUserId"]
      ..feteScore = json["feteScore"];
  }

  @override
  Map toJson() {
    return {
      "uid": this.uid,
      "username": this.username,
      "email": this.email,
      "name": this.name,
      "phoneNumber": this.phoneNumber ?? "",
      "isActivated": this.isActivated,
      "profilePictureUrl": this.profilePictureUrl ?? "",
      "facebookId": this.facebookId ?? "",
      "twitterId": this.twitterId ?? "",
      "spotifyUserId": this.spotifyUserId ?? "",
      "deezerUserId": this.deezerUserId ?? "",
      "feteScore": this.feteScore ?? "",
    };
  }
}

class Personality extends User {
  bool isVerified;
  String bio;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..isVerified = json["isVerified"]
      ..bio = json["bio"];
  }

  @override
  Map toJson() {
    Map json = super.toJson();
    json.addAll({
      "isVerified": this.isVerified,
      "bio": this.bio,
    });
    return json;
  }
}

class Artist extends Personality {
  String spotifyArtistId;
  String deezerArtistId;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..spotifyArtistId = json["spotifyArtistId"]
      ..deezerArtistId = json["deezerArtistId"];
  }

  @override
  Map toJson() {
    Map json = super.toJson();
    json.addAll({
      "spotifyArtistId": this.spotifyArtistId ?? "",
      "deezerArtistId": this.deezerArtistId ?? "",
    });
    return json;
  }
}

typedef Team TeamLoader(String teamId);

class Fan extends User {
  Team team;
  TeamLoader teamLoader;

  Fan({
    this.teamLoader,
  });

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this..team = teamLoader(json["teamId"]);
  }

  @override
  Map toJson() {
    Map json = super.toJson();
    json.addAll({
      "teamId": this.team.id,
    });
    return json;
  }
}
