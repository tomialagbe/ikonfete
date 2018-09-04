import 'package:ikonfetemobile/model/model.dart';
import 'package:ikonfetemobile/model/user.dart';

class Team extends Model<String> {
  Personality teamOwner;

  @override
  void fromJson(Map json) {}

  @override
  Map toJson() {
    // TODO: implement toJson
  }
}
