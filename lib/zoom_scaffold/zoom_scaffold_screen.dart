import 'package:flutter/material.dart';
import 'package:ikonfetemobile/zoom_scaffold/menu.dart';
import 'package:ikonfetemobile/zoom_scaffold/menu_screen.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';

class ZoomScaffoldScreen extends StatefulWidget {
  final bool isArtist;
  final String screenId;
  final Map<String, String> params;

  ZoomScaffoldScreen({
    @required this.isArtist,
    @required this.screenId,
    this.params,
  });

  @override
  _ZoomScaffoldScreenState createState() => _ZoomScaffoldScreenState();
}

class _ZoomScaffoldScreenState extends State<ZoomScaffoldScreen> {
  String selectedMenuItemId;
  Screen activeScreen;

  @override
  void initState() {
    super.initState();
    selectedMenuItemId = defaultMenuItem(isArtist: widget.isArtist).id;
    activeScreen = defaultScreen(isArtist: widget.isArtist);
  }

  @override
  Widget build(BuildContext context) {
    return new ZoomScaffold(
      menuScreen: MenuScreen(
        menu: zoomScaffoldMenu(isArtist: widget.isArtist),
        selectedItemId: selectedMenuItemId,
        onMenuItemSelected: (String itemId) {
          selectedMenuItemId = itemId;
          final screen =
              zoomScaffoldScreen(selectedMenuItemId, isArtist: widget.isArtist);
          setState(() => activeScreen = screen);
        },
      ),
      contentScreen: activeScreen,
    );
  }
}
