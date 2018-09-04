abstract class Model<T> {
  T id;

  void fromJson(Map json);

  Map toJson();
}
