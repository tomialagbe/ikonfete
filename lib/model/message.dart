import 'package:ikonfetemobile/model/model.dart';
import 'package:mime/mime.dart';

class Message extends Model<String> {
  String senderUid;
  String recipientUid;
  String bodyText;
  DateTime sendDateTime;
  List<MessageAttachment> attachments;

  @override
  void fromJson(Map json) {
    super.fromJson(json);
    this
      ..senderUid = json["senderUid"]
      ..recipientUid = json["recipientUid"]
      ..bodyText = json["bodyText"] ?? ""
      ..sendDateTime =
          DateTime.fromMillisecondsSinceEpoch(json["sendDateTime"]);

    List<MessageAttachment> attachments = [];
    List attachmentMapList = json["attachments"];
    for (var a in attachmentMapList) {
      final mediaUrl = a["mediaUrl"];
      final attachment = getAttachmentForMimeType(mediaUrl);
      if (attachment == null) {
        continue; // TODO: handle this properly
      }
      attachments.add(attachment);
    }
    this.attachments = attachments;
  }

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    map.addAll({
      "senderUid": senderUid,
      "recipientUid": recipientUid,
      "bodyText": bodyText ?? "",
      "sendDateTime": sendDateTime.millisecondsSinceEpoch,
    });
    List<Map> attachmentMapList = [];
    for (var att in attachments) {
      final m = {
        "mimeType": lookupMimeType(att.mediaUrl),
        "mediaUrl": att.mediaUrl,
      };
      attachmentMapList.add(m);
    }
    map["attachments"] = attachmentMapList;
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
