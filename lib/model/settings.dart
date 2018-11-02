import 'package:ikonfetemobile/model/model.dart';

class Settings extends Model<String> {
  String uid;
  String deezerUserId;
  String spotifyUserId;
  bool enableNotifications;

  Settings.empty() {
    this
      ..id = null
      ..uid = null
      ..deezerUserId = null
      ..spotifyUserId = null
      ..enableNotifications = false;
  }

  Settings();

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..uid = json["uid"]
      ..deezerUserId = json["deezerUserId"] ?? ""
      ..spotifyUserId = json["spotifyUserId"] ?? ""
      ..enableNotifications = json["enableNotifications"] ?? false;
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      "uid": uid,
      "deezerUserId": deezerUserId ?? "",
      "spotifyUserId": spotifyUserId ?? "",
      "enableNotifications": enableNotifications ?? false,
    });
    return data;
  }
}
