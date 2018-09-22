abstract class Model<T> {
  String id;

  void fromJson(Map json) {
    this..id = json["id"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
    };
  }
}
