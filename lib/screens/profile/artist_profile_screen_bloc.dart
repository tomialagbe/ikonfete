import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/repository/artist_repository.dart';

class ArtistData {
  Artist artist;
  FirebaseUser user;
}

class ArtistProfileScreenBloc extends BlocBase {
  /// StreamController that handles artist UIDs
  StreamController<String> _loadArtistActionController =
      StreamController<String>();

  /// StreamController that handles load artist results
  StreamController<ArtistData> _loadArtistResultController =
      StreamController.broadcast<ArtistData>();

  Sink<String> get loadArtist => _loadArtistActionController.sink;

  Stream<ArtistData> get loadArtistResult => _loadArtistResultController.stream;

  ArtistProfileScreenBloc() {
    _loadArtistActionController.stream.listen(_loadArtist);
  }

  @override
  void dispose() {
    _loadArtistActionController.close();
    _loadArtistResultController.close();
  }

  void _loadArtist(String uid) async {
    final artistRepo = ArtistRepository();
    final artist = await artistRepo.findByUid(uid);
    final currentUser = await FirebaseAuth.instance.currentUser();
    final artistData = ArtistData()
      ..artist = artist
      ..user = currentUser;
    _loadArtistResultController.add(artistData);
  }
}
