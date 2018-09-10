abstract class Model<T> {
  String id;

  void fromJson(Map json) {
    this..id = json["id"];
  }

  Map toJson() {
    return {
      "id": id,
    };
  }
}
