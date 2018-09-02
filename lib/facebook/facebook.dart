import 'package:meta/meta.dart';

class FacebookConfig {
  FacebookConfig({
    @required this.appId,
    @required this.appSecret,
  });

  final String appId;
  final String appSecret;
}

class Token {
  final String access;
  final String type;
  final num expiresIn;

  Token(this.access, this.type, this.expiresIn);

  Token.fromMap(Map<String, dynamic> json)
      : access = json['access_token'],
        type = json['token_type'],
        expiresIn = json['expires_in'];
}

class Id {
  final String id;

  Id(this.id);
}

class Cover {
  final String id;
  final int offsetY;
  final String source;

  Cover(this.id, this.offsetY, this.source);

  Cover.fromMap(Map<String, dynamic> json)
      : id = json['id'],
        offsetY = json['offset_y'],
        source = json['source'];
}

class PublicProfile extends Id {
  final Cover cover;
  final String name;

  PublicProfile.fromMap(Map<String, dynamic> json)
      : cover =
            json.containsKey('cover') ? new Cover.fromMap(json['cover']) : null,
        name = json['name'],
        super(json['id']);
}
