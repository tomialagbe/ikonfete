import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';

class UploadResult {
  final String fileName;
  final String fileDownloadUrl;

  UploadResult({@required this.fileName, @required this.fileDownloadUrl});
}

class CloudStorageUploadHelper {
  Future<UploadResult> uploadProfilePicture(
      FirebaseStorage firebaseStorage, String uid, File file) async {
    final fileExtension = extension(file.path);
    String fileName = "$uid$fileExtension";
    StorageReference ref =
        firebaseStorage.ref().child("profile_pictures").child("$fileName");
    final uploadTask = ref.putFile(file, StorageMetadata());

    final snapshot = await uploadTask.onComplete;
    String downloadUrl = await snapshot.ref.getDownloadURL();
//    String downloadUrl = snapshot.downloadUrl.toString();
    return UploadResult(fileName: fileName, fileDownloadUrl: downloadUrl);
  }

  Future<bool> deleteProfilePicture(
      FirebaseStorage firebaseStorage, String uid) {
    return deleteFile(firebaseStorage, "profile_pictures", "$uid.jpg");
  }

  Future<bool> deleteFile(
      FirebaseStorage firebaseStorage, String path, String fileName) async {
    try {
      await firebaseStorage.ref().child(path).child(fileName).delete();
      return true;
    } on Exception catch (e) {
      print(e.toString());
      return false;
    }
  }
}
