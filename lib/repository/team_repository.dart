import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ikonfetemobile/bloc/collections.dart';
import 'package:ikonfetemobile/model/pagination.dart';
import 'package:ikonfetemobile/model/team.dart';
import 'package:ikonfetemobile/repository/firestore_helpers.dart';

class TeamRepository {
  Future<Team> findArtistTeam(String artistUid) {
    return FirestoreHelpers.findOneByParam(
        firestore: Firestore.instance,
        collection: Collections.teams,
        paramName: "artist.uid",
        val: artistUid);
  }

  Future<Page<Team>> findAllTeams(int pageSize, {Team lastFetched}) async {
    final collection = Firestore.instance.collection(Collections.teams);
    var query =
        collection.orderBy("teamSize", descending: true).limit(pageSize);
    if (lastFetched != null) {
      query = query.startAfter([
        {'artist.uid': lastFetched.artist.uid},
      ]);
    }

    final querySnapshot = await query.getDocuments();
    final documentSnapshots = querySnapshot.documents;
    List<Team> artistTeams = documentSnapshots.map((docsnapshot) {
      final d = docsnapshot.data;
      return Team()..fromJson(docsnapshot.data);
    }).toList();
    return Page.from(items: artistTeams, pageSize: pageSize);
  }

  Future<List<Team>> searchTeamsByArtistName(
      String searchQuery, int resultSize) async {
    // TODO: change to fetch only verified users
    final collection = Firestore.instance.collection(Collections.teams);
//    var query = collection.orderBy("a", descending: true).startAt([
//      {"artist.name": searchQuery}
//    ]).endAt([
//      {"artist.name": searchQuery + '\uf8ff'}
//    ]).limit(resultSize);
    var query = collection
        .orderBy("artist.name")
        .startAt([searchQuery]).endAt([searchQuery + '\uf8ff']);
//    var query = collection
//        .where("artist.name", isEqualTo: searchQuery)
//        .orderBy("teamSize", descending: true)
//        .limit(resultSize);
    final querySnapshot = await query.getDocuments();
    return querySnapshot.documents
        .map((docsnapshot) => Team()..fromJson(docsnapshot.data))
        .toList();
  }
}
