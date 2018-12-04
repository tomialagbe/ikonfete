import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/app_config.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/model/message.dart';
import 'package:ikonfetemobile/screens/messages/chat_bloc.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/random_gradient_image.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

//Screen messageScreen({bool isArtist: true, Fan recipient}) {
//  return Screen(
//    titleBuilder: (ctx) => Container(),
//    contentBuilder: (ctx) => MessagesScreen(),
//  );
//}

final messagesScreen = Screen(
    title: "MESSAGES",
    contentBuilder: (ctx) {
      final appConfig = AppConfig.of(ctx);
      // TODO: fix
      BlocProvider<ChatBloc>(
        bloc: ChatBloc(appConfig: appConfig),
        child: MessagesScreen(isArtist: false),
      );
    });

class MessagesScreen extends StatefulWidget {
  final bool isArtist;
  final Fan recipient;

  MessagesScreen({
    @required this.isArtist,
    this.recipient,
  });

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _chatTextController;
  ChatBloc _bloc;
  List<StreamSubscription> _subscriptions = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    _chatTextController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      _bloc = BlocProvider.of<ChatBloc>(context);
      _subscriptions
          .add(_bloc.sendResponse.listen(null)..onError(_handleMessageError));
    }
  }

  @override
  void dispose() {
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
    super.dispose();
  }

  void _handleMessageError(Object error) {
    scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text(error.toString()), key: scaffoldKey));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(FontAwesome5Icons.angleLeft, color: Colors.black54),
          tooltip: "Back",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: _buildTitle(),
        titleSpacing: 0.0,
        centerTitle: false,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: <Widget>[
            Flexible(
              child: StreamBuilder<List<Message>>(
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  return ListView.builder(itemBuilder: (ctx, index) {
                    final message = snapshot.data[index];
                    bool fromRecipient =
                        message.senderUid == widget.recipient.uid;
                    // message was sent by recipient
                    return fromRecipient
                        ? _buildRecipientChatItem(message)
                        : _buildSenderChatItem(message);
                  });
                },
              ),
            ),
            Divider(
              height: 1.0,
              color: Colors.black38,
            ),
            new Container(
              height: 60.0,
              padding:
                  EdgeInsets.only(left: 0.0, right: 0.0, top: 5.0, bottom: 0.0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
//                    IconButton(
//                      onPressed: () {},
//                      padding: EdgeInsets.all(2.0),
//                      iconSize: 25.0,
//                      icon: Icon(
//                        FontAwesome5Icons.grinAlt,
//                        color: Colors.grey,
//                      ),
//                    ),
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.all(2.0),
                      iconSize: 25.0,
                      icon: Icon(
                        LineAwesomeIcons.paperclip,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      width: 0.5,
                      height: double.infinity,
                      color: Colors.black38,
                    ),
                    SizedBox(width: 5.0),
                    Expanded(child: _buildMessageTextField()),
                    SizedBox(width: 5.0),
                    IconButton(
                      onPressed: _chatTextController.text.isEmpty
                          ? _takePicture
                          : _sendMessage,
                      padding: EdgeInsets.all(2.0),
                      iconSize: 25.0,
                      icon: Icon(
                        _chatTextController.text.isEmpty
                            ? FontAwesome5Icons.camera
                            : FontAwesome5Icons.paperPlane,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final children = <Widget>[];
    if (widget.isArtist) {
      if (StringUtils.isNullOrEmpty(widget.recipient.profilePictureUrl)) {
        children.add(RandomGradientImage());
      } else {
        children.add(
          RandomGradientImage(
            height: 50.0,
            width: 50.0,
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(
                  widget.recipient.profilePictureUrl),
            ),
          ),
        );
      }
    } else {
      children.add(RandomGradientImage()); // TODO: handle fan side
    }

    children.addAll(<Widget>[
      SizedBox(width: 10.0),
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.isArtist
                ? widget.recipient.name
                : "", // TODO: handle fan side
            style: TextStyle(fontSize: 18.0, color: Colors.black87),
          ),
          Text(
            "Online",
            style: TextStyle(fontSize: 14.0, color: Colors.black87),
          ), // TODO: implement presence
        ],
      ),
    ]);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildMessageTextField() {
    return TextField(
      autofocus: false,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.newline,
      maxLines: null,
      decoration: InputDecoration(filled: false, border: InputBorder.none),
      controller: _chatTextController,
      onChanged: (String newVal) {
        setState(() {});
      },
    );
  }

  Widget _buildRecipientChatItem(Message message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 300.0,
          color: primaryColor.withOpacity(0.5),
          child: Text(message.bodyText),
        ),
      ],
    );
  }

  Widget _buildSenderChatItem(Message message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 300.0,
          color: primaryColor.withOpacity(0.5),
          child: Text(message.bodyText),
        ),
      ],
    );
  }

  void _takePicture() {}

  void _sendMessage() {
    final initState = BlocProvider.of<ApplicationBloc>(context).initState;
    final senderUID = initState.currentUser.uid;
    final senderName = initState.currentUser.displayName;
    final senderUsername =
        initState.isArtist ? initState.artist.username : initState.fan.username;
    final message = Message()
      ..senderUid = senderUID
      ..recipientUid = widget.recipient.uid
      ..senderName = senderName
      ..senderUsername = senderUsername
      ..sendDateTime = DateTime.now()
      ..bodyText = _chatTextController.text;
    _bloc.messageSender.add(message);
    _chatTextController.clear();
  }
}
