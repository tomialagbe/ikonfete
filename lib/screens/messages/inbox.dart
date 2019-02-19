import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

// artists get an inbox
final inboxScreen = Screen(
  title: "Inbox",
  contentBuilder: (ctx) => InboxScreen(),
//  contentBuilder: (ctx) => BlocProvider<InboxBloc>(
//        bloc: InboxBloc(appConfig: AppConfig.of(ctx)),
//        child: InboxScreen(),
//      ),
);

class InboxScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text("INBOX"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        backgroundColor: primaryColor,
        tooltip: "New Message",
        child: Icon(
          FontAwesome5Icons.pencilAlt,
          size: 25.0,
        ),
      ),
    );
  }
}

//class InboxScreen extends StatefulWidget {
//  @override
//  _InboxScreenState createState() => _InboxScreenState();
//}
//
//class _InboxScreenState extends State<InboxScreen> {
//  String artistUid;
//  InboxBloc _bloc;
//  List<StreamSubscription> _subscriptions = <StreamSubscription>[];
//
//  @override
//  void initState() {
//    super.initState();
//    artistUid =
//        BlocProvider.of<ApplicationBloc>(context).initState.currentUser.uid;
//  }
//
//  @override
//  void didChangeDependencies() {
//    super.didChangeDependencies();
//    if (_bloc == null) {
//      _bloc = BlocProvider.of<InboxBloc>(context);
//    }
//  }
//
//  @override
//  void dispose() {
//    _subscriptions.forEach((s) => s.cancel());
//    _subscriptions.clear();
//    super.dispose();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      backgroundColor: Colors.white,
//      body: Container(
//        width: double.infinity,
//        height: double.infinity,
//        child: Center(
//          child: Text("INBOX"),
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _newMessage,
//        backgroundColor: primaryColor,
//        tooltip: "New Message",
//        child: Icon(
//          FontAwesome5Icons.pencilAlt,
//          size: 25.0,
//        ),
//      ),
//    );
//  }
//
//  void _newMessage() async {
//    final messageRecipient = await Navigator.push<Fan>(
//      context,
//      CupertinoPageRoute(
//          builder: (ctx) => MessageRecipientSelector(
//                inboxBloc: _bloc,
//                artistUid: artistUid,
//              )),
//    );
//
//    if (messageRecipient != null) {
//      final appConfig = AppConfig.of(context);
//      Navigator.push(
//          context,
//          CupertinoPageRoute(
//              builder: (ctx) => BlocProvider<ChatBloc>(
//                    bloc: ChatBloc(appConfig: appConfig),
//                    child: MessagesScreen(
//                        isArtist: true, recipient: messageRecipient),
//                  )));
//    }
//  }
//}
