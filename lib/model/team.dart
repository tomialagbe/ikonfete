import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/model.dart';

class Team extends Model<String> {
  Artist artist;
  int teamSize = 0;
  String teamPictureUrl;
  DateTime dateCreated;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..teamSize = json["teamSize"] ?? 0
      ..teamPictureUrl = json["teamPictureUrl"] ?? ""
      ..dateCreated = json["dateCreated"] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(json["dateCreated"] * 1000);
    final artistMap = json["artist"];
    this.artist = Artist()..fromJson(artistMap);
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      "teamSize": teamSize ?? 0,
      "teamPictureUrl": teamPictureUrl ?? "",
      "dateCreated": dateCreated == null
          ? null
          : dateCreated.millisecondsSinceEpoch / 1000,
      "artist": artist.toJson(),
    });
    return map;
  }
}
