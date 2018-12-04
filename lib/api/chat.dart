import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ikonfetemobile/model/message.dart';
import 'package:meta/meta.dart';

class ChatApi {
  final Firestore firestore;
  final FirebaseStorage firebaseStorage;

  ChatApi({@required this.firestore, @required this.firebaseStorage});

  Stream<List<Message>> getMessagesBetween(String uid1, String uid2) {
    return firestore
        .collection("messages")
        .where("members", arrayContains: uid1)
        .where("members", arrayContains: uid2)
        .snapshots()
        .map((snapshot) {
      final docSnapshots = snapshot.documents;
      List<Message> messages =
          docSnapshots.map((ds) => Message()..fromJson(ds.data)).toList();
      return messages;
    });
  }

  Future sendMessage(Message message) async {
    return firestore
        .collection("messages")
        .document()
        .setData(message.toJson());
  }
}
