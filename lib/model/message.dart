import 'package:ikonfetemobile/model/model.dart';
import 'package:mime/mime.dart';

class Message extends Model<String> {
  String _senderUid;
  String _recipientUid;
  String senderName;
  String senderUsername;
  String bodyText;
  DateTime sendDateTime;
  Set<String> members = Set();
  List<MessageAttachment> attachments;

  set senderUid(String val) {
    _senderUid = val;
    members.add(val);
  }

  String get senderUid => _senderUid;

  set recipientUid(String val) {
    _recipientUid = val;
    members.add(val);
  }

  String get recipientUid => _recipientUid;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      .._senderUid = json["senderUid"]
      .._recipientUid = json["recipientUid"]
      ..senderName = json["senderName"]
      ..senderUsername = json["senderUsername"]
      ..bodyText = json["bodyText"] ?? ""
      ..sendDateTime =
          DateTime.fromMillisecondsSinceEpoch(json["sendDateTime"]);

    List<String> members = [];
    for (var m in json["members"] ?? []) {
      members.add(m);
    }
    this.members = Set.from(members);

//    List<MessageAttachment> attachments = [];
//    List attachmentMapList = json["attachments"];
//    for (var a in attachmentMapList) {
//      final mediaUrl = a["mediaUrl"];
//      final attachment = getAttachmentForMimeType(mediaUrl);
//      if (attachment == null) {
//        continue; // TODO: handle this properly
//      }
//      attachments.add(attachment);
//    }
//    this.attachments = attachments;
    // TODO: attachments later
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      "senderUid": _senderUid,
      "recipientUid": _recipientUid,
      "senderName": senderName,
      "senderUsername": senderUsername,
      "bodyText": bodyText ?? "",
      "sendDateTime": sendDateTime.millisecondsSinceEpoch,
      "members": members.toList(),
    });
//    List<Map> attachmentMapList = [];
//    for (var att in attachments) {
//      final m = {
//        "mimeType": lookupMimeType(att.mediaUrl),
//        "mediaUrl": att.mediaUrl,
//      };
//      attachmentMapList.add(m);
//    }
//    map["attachments"] = attachmentMapList;
    return map;
  }

  MessageAttachment getAttachmentForMimeType(String fileUri) {
    String mimeType = lookupMimeType(fileUri);
    if (mimeType.contains("audio")) {
      return AudioAttachment()
        ..mimeType = mimeType
        ..mediaUrl = fileUri;
    } else if (mimeType.contains("video")) {
      return VideoAttachment()
        ..mimeType = mimeType
        ..mediaUrl = fileUri;
    } else if (mimeType.contains("image")) {
      return ImageAttachment()
        ..mimeType = mimeType
        ..mediaUrl = fileUri;
    } else {
      return null;
    }
  }
}

abstract class MessageAttachment {
  String mimeType;
  String mediaUrl;
}

class VideoAttachment extends MessageAttachment {}

class ImageAttachment extends MessageAttachment {}

class AudioAttachment extends MessageAttachment {}
