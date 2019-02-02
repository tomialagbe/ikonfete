import 'dart:io';

import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/utils/types.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbProvider {
  DbProvider._();

  static final DbProvider db = DbProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDb();
    return _database;
  }

  Future<Database> initDb() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, "Ikonfete.db");
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (db, int version) async {
        await _createArtistTable(db);
        await _createFanTable(db);
      },
    );
  }

  Future<void> _createArtistTable(Database db) async {
    return db.execute("CREATE TABLE Artist ("
        "id TEXT NOT NULL PRIMARY KEY, "
        "uid TEXT NOT NULL, "
        "username TEXT, "
        "name TEXT NOT NULL, "
        "email TEXT NOT NULL, "
        "country TEXT, "
        "countryIsoCode TEXT, "
        "facebookId TEXT, "
        "twitterId TEXT, "
        "spotifyUserId TEXT, "
        "deezerUserId TEXT, "
        "dateCreated INTEGER, "
        "dateUpdated INTEGER, "
        "isVerified INTEGER, "
        "dateVerified INTEGER, "
        "isPendingVerification INTEGER, "
        "bio TEXT, "
        "spotifyArtistId TEXT, "
        "deezerArtistId TEXT, "
        "profilePictureUrl TEXT, "
        "feteScore INTEGER )");
  }

  Future<void> _createFanTable(Database db) {
    return db.execute("CREATE TABLE Fan ("
        "id TEXT NOT NULL PRIMARY KEY, "
        "uid TEXT NOT NULL, "
        "username TEXT, "
        "name TEXT NOT NULL, "
        "email TEXT NOT NULL, "
        "country TEXT, "
        "countryIsoCode TEXT, "
        "facebookId TEXT, "
        "twitterId TEXT, "
        "currentTeamId TEXT, "
        "profilePictureUrl TEXT, "
        "feteScore INTEGER )");
  }

  Future<bool> setCurrentArtist(Artist artist) async {
    await clearCurrentArtistOrFan();
    int insertId = await _database.insert("Artist", artist.toJson());
    return insertId > 0;
  }

  Future<void> clearCurrentArtistOrFan() async {
    await _clearCurrentArtist();
    await _clearCurrentFan();
  }

  Future<void> _clearCurrentArtist() async {
    await _database.delete("Artist", where: null);
  }

  Future<Artist> getCurrentArtist() async {
    final result = await _database.query("Artist", limit: 1);
    if (result.isNotEmpty) {
      Artist artist = Artist()..fromJson(result.first);
      return artist;
    }
    return null;
  }

  Future<bool> setCurrentFan(Fan fan) async {
    await _clearCurrentArtist();
    await _clearCurrentFan();
    int insertId = await _database.insert("Fan", fan.toJson());
    return insertId > 0;
  }

  Future<void> _clearCurrentFan() async {
    await _database.delete("Fan", where: null);
  }

  Future<Fan> getCurrentFan() async {
    final result = await _database.query("Fan", limit: 1);
    if (result.isNotEmpty) {
      Fan fan = Fan()..fromJson(result.first);
      return fan;
    }
    return null;
  }

  Future<ExclusivePair<Artist, Fan>> getArtistOrFanByUid(String uid) async {
    Artist artist;
    Fan fan;
    artist = await getCurrentArtist();
    if (artist != null && artist.uid == uid) {
      return ExclusivePair.withFirst(artist);
    }

    fan = await getCurrentFan();
    if (fan != null && fan.uid == uid) {
      return ExclusivePair.withSecond(fan);
    }
    throw ArgumentError("User $uid not found");
  }
}
