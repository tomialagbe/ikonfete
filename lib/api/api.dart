import 'package:ikonfetemobile/model/model.dart';

abstract class Api {
  String apiBaseUrl;

  Api(this.apiBaseUrl);
}

class ApiError extends Model {
  String error;

  @override
  void fromJson(Map json) {
    this..error = json["error"];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "error": this.error,
    };
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() {
    return message;
  }
}
