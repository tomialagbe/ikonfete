import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/model/fan.dart';
import 'package:ikonfetemobile/screens/messages/inbox_bloc.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/widget/form_fields.dart';
import 'package:ikonfetemobile/widget/hud_overlay.dart';
import 'package:ikonfetemobile/widget/random_gradient_image.dart';

class MessageRecipientSelector extends StatefulWidget {
  final String artistUid;
  final InboxBloc inboxBloc;

  MessageRecipientSelector({
    @required this.artistUid,
    @required this.inboxBloc,
  });

  @override
  MessageRecipientSelectorState createState() {
    return new MessageRecipientSelectorState();
  }
}

class MessageRecipientSelectorState extends State<MessageRecipientSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
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
        title: Text(
          "Select Recipient",
          style: TextStyle(fontSize: 20.0, color: Colors.black54),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding:
            EdgeInsets.only(left: 20.0, right: 20.0, top: 0.0, bottom: 20.0),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.only(top: 10.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    SearchField(
                      placeholder: "search fans...",
                      onChanged: (String val) {},
                    ),
                  ],
                ),
              ),
            ),
            StreamBuilder<List<Fan>>(
              stream: widget.inboxBloc.teamMembers,
              initialData: null,
              builder: (ctx, snapshot) {
                if (!snapshot.hasData && !snapshot.hasError) {
                  return SliverFixedExtentList(
                    itemExtent: 100.0,
                    delegate: SliverChildListDelegate(<Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: HudOverlay.dotsLoadingIndicator(),
                      ),
                    ]),
                  );
                } else if (snapshot.hasError) {
                  // TODO: handle errors
                  return SliverFixedExtentList(
                    itemExtent: 100.0,
                    delegate: SliverChildListDelegate(<Widget>[
                      Container(
                          alignment: Alignment.center,
                          child: Text(snapshot.error)),
                    ]),
                  );
                } else {
                  return SliverPadding(
                    padding: EdgeInsets.only(top: 20.0),
                    sliver: SliverFixedExtentList(
                      itemExtent: 90.0,
                      delegate: SliverChildBuilderDelegate(
                        (ctx, index) {
                          final fan = snapshot.data[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: _buildFanListTile(fan),
                          );
                        },
                        childCount: snapshot.data.length,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFanListTile(Fan fan) {
    return ListTile(
      contentPadding: EdgeInsets.all(0.0),
      leading: StringUtils.isNullOrEmpty(fan.profilePictureUrl)
          ? RandomGradientImage()
          : RandomGradientImage(
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.transparent,
                backgroundImage:
                    CachedNetworkImageProvider(fan.profilePictureUrl),
              ),
            ),
      title: Text(
        fan.name,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Text(
        //followers
        "${fan.feteScore}",
        style: TextStyle(
          fontSize: 13.0,
          color: Color(0xFF707070),
        ),
      ),
      subtitle: Text(
        "@${fan.username}",
        style: TextStyle(
          fontSize: 13.0,
          color: Color(0xFF707070),
        ),
      ),
      enabled: true,
      onTap: () {
        Navigator.of(context).pop(fan);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    widget.inboxBloc.loadTeamMembers(widget.artistUid);
  }
}
