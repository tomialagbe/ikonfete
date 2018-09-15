import 'package:ikonfetemobile/model/model.dart';

class PendingVerification extends Model<String> {
  String uid; // the uid of the artist or personality pending verification
  DateTime dateCreated;
  String facebookId;
  String twitterId;
  String twitterUsername;
  String bio;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..uid = json["uid"]
      ..facebookId = json["facebookId"] ?? ""
      ..twitterId = json["twitterId"] ?? ""
      ..twitterUsername = json["twitterUsername"] ?? ""
      ..dateCreated = json["dateCreated"] != null
          ? DateTime.fromMillisecondsSinceEpoch(json["dateCreated"])
          : null;
  }

  @override
  Map toJson() {
    final map = super.toJson();
    map.addAll({
      "uid": uid,
      "dateCreated": dateCreated.millisecondsSinceEpoch / 1000,
      "facebookId": facebookId ?? "",
      "twitterId": twitterId ?? "",
      "twitterUsername": twitterUsername ?? "",
      "bio": bio,
    });
    return map;
  }
}
