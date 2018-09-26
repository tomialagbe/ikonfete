import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ikonfetemobile/bloc/collections.dart';
import 'package:ikonfetemobile/model/artist.dart';
import 'package:ikonfetemobile/model/pagination.dart';
import 'package:ikonfetemobile/repository/firestore_helpers.dart';

class ArtistRepository {
  Future<Artist> findByUid(String uid) async {
    return FirestoreHelpers.findOneByParam(
      firestore: Firestore.instance,
      collection: Collections.artists,
      paramName: "uid",
      val: uid,
      entityConverter: (data) => Artist()..fromJson(data),
    );
  }

  Future<Artist> findByUsername(String username) async {
    return FirestoreHelpers.findOneByParam(
      firestore: Firestore.instance,
      collection: Collections.artists,
      paramName: "username",
      val: username,
      entityConverter: (data) => Artist()..fromJson(data),
    );
  }

  Future<Page<Artist>> findAllArtists(int pageSize,
      {Artist lastFetched}) async {
    final collection = Firestore.instance.collection(Collections.artists);
    var query = collection.orderBy("name", descending: true).limit(pageSize);
    if (lastFetched != null) {
      query = query.startAfter([
        {'uid': lastFetched.uid},
      ]);
    }
    final querySnapshot = await query.getDocuments();
    final documentSnapshots = querySnapshot.documents;
    List<Artist> artistList = documentSnapshots
        .map((docSnapshot) => Artist()..fromJson(docSnapshot.data))
        .toList();
    final page = Page<Artist>.from(items: artistList, pageSize: pageSize);
    return page;
  }

  Future<List<Artist>> searchArtistsByName(String searchQuery, int resultSize,
      {Artist lastFetched}) async {
    final collection = Firestore.instance.collection(Collections.artists);
    var query = collection.orderBy("name", descending: true).startAt([
      {"name": searchQuery}
    ]).endAt([
      {"name": searchQuery + '\uf8ff'}
    ]).limit(resultSize);
    final querySnapshot = await query.getDocuments();
    return querySnapshot.documents
        .map((docsnapshot) => Artist()..fromJson(docsnapshot.data))
        .toList();
  }
}
