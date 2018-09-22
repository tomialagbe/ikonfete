import 'package:ikonfetemobile/model/model.dart';

class Fan extends Model<String> {
  String uid;
  String username;
  String name;
  String facebookId;
  String twitterId;
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
      ..feteScore = json["feteScore"] ?? 0;
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
      "feteScore": this.feteScore ?? 0,
    });
    return map;
  }
}
