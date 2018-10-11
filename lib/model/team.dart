import 'package:ikonfetemobile/model/model.dart';

class Team extends Model<String> {
  String artistId;
  String artistUid;
  String artistName;
  String teamPictureUrl;
  DateTime dateCreated;
  DateTime dateUpdated;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..artistId = json["artistId"] ?? ""
      ..artistUid = json["artistUid"] ?? ""
      ..artistName = json["artistName"] ?? ""
      ..teamPictureUrl = json["teamPictureUrl"] ?? ""
      ..dateCreated = json["dateCreated"] == null || json["dateCreated"] == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json["dateCreated"] * 1000)
      ..dateUpdated = json["dateUpdated"] == null || json["dateUpdated"] == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json["dateUpdated"] * 1000);
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      "artistId": artistId ?? "",
      "artistUid": artistUid ?? "",
      "artistName": artistName ?? "",
      "teamPictureUrl": teamPictureUrl ?? "",
      "dateCreated": dateCreated == null
          ? null
          : dateCreated.millisecondsSinceEpoch / 1000,
      "dateUpdated": dateUpdated == null
          ? null
          : dateUpdated.millisecondsSinceEpoch / 1000,
    });
    return map;
  }
}
