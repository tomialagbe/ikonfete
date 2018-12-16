import 'dart:async';

import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/model/message.dart';
import 'package:meta/meta.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

class ChatBloc extends BlocBase {
  final AppConfig appConfig;

  StreamController<Message> _sendController = StreamController<Message>();
  StreamController<Message> _recieveController = StreamController<Message>();

  StreamController _sendResponse = StreamController();

  Stream<Message> get recievedMessages => _recieveController.stream;

  Sink<Message> get messageSender => _sendController.sink;

  Stream get sendResponse => _sendResponse.stream;

  ChatBloc({@required this.appConfig}) {
    _sendController.stream.listen(_sendMessage);
  }

  @override
  void dispose() {
    _sendController.close();
    _recieveController.close();
    _sendResponse.close();
  }

  void _sendMessage(Message message) async {
//    try {
//      final firestore = Firestore.instance;
//      final chatApi = ChatApi(
//          firestore: firestore, firebaseStorage: FirebaseStorage.instance);
//      await chatApi.sendMessage(message);
//      _sendResponse.add(null);
//    } on PlatformException catch (e) {
//      _sendResponse.addError(e.message);
//    } on Exception catch (e) {
//      _sendResponse.addError(e.toString());
//    }
  }
}
