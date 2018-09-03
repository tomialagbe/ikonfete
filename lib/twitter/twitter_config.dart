import 'package:meta/meta.dart';

class TwitterConfig {
  TwitterConfig({
    @required this.consumerKey,
    @required this.consumerSecret,
    @required this.accessToken,
    @required this.accessTokenSecret,
  });

  final String consumerKey;
  final String consumerSecret;
  final String accessToken;
  final String accessTokenSecret;
}
