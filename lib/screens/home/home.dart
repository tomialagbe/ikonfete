import 'package:ikonfetemobile/screens/home/artist_home.dart';
import 'package:ikonfetemobile/screens/home/fan_home.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';
import 'package:meta/meta.dart';

Screen homeScreen({@required bool isArtist}) {
  if (isArtist) {
    return artistHomeScreen;
  } else {
    return fanHomeScreen;
  }
}
