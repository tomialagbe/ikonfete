import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelpers {
  static Future<T> findOneByParam<T>({
    Firestore firestore,
    String collection,
    String paramName,
    String val,
    T entityConverter(Map<String, dynamic> data),
  }) async {
    final querySnapshot = await firestore
        .collection(collection)
        .where(paramName, isEqualTo: val)
        .limit(1)
        .getDocuments();
    if (querySnapshot.documents.isEmpty) {
      return null;
    } else {
      return entityConverter(querySnapshot.documents[0].data);
    }
  }
}
