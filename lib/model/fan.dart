import 'package:ikonfetemobile/model/model.dart';

class Fan extends Model<String> {
  String uid;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this..uid = json["uid"];
  }

  @override
  Map toJson() {
    final map = super.toJson();
    map.addAll({
      "uid": this.uid,
    });
    return map;
  }
}
