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

  @override
  bool operator ==(other) =>
      identical(this, other) &&
      other is Settings &&
      runtimeType == other.runtimeType &&
      id == other.id &&
      uid == other.uid &&
      deezerUserId == other.deezerUserId &&
      spotifyUserId == other.spotifyUserId &&
      enableNotifications == other.enableNotifications;

  @override
  int get hashCode =>
      id.hashCode ^
      uid.hashCode ^
      deezerUserId.hashCode ^
      spotifyUserId.hashCode ^
      enableNotifications.hashCode;
}
