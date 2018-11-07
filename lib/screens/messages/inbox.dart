import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/screens/messages/inbox_bloc.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

// artists get an inbox
final inboxScreen = Screen(
  title: "Inbox",
  contentBuilder: (ctx) => BlocProvider<InboxBloc>(
        bloc: InboxBloc(),
        child: InboxScreen(),
      ),
);

class InboxScreen extends StatefulWidget {
  @override
  _InboxScreenState createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
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
        onPressed: _newMessage,
        backgroundColor: primaryColor,
        tooltip: "New Message",
        child: Icon(
          FontAwesome5Icons.plus,
          size: 20.0,
        ),
      ),
    );
  }

  void _newMessage() {
    // TODO: show selection dialog
  }
}
