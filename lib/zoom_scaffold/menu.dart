import 'package:ikonfetemobile/screens/home/home.dart';
import 'package:ikonfetemobile/screens/ikonscreen/ikons.dart';
import 'package:ikonfetemobile/screens/inbox/inbox.dart';
import 'package:ikonfetemobile/screens/messages.dart';
import 'package:ikonfetemobile/screens/settings/settings.dart';
import 'package:ikonfetemobile/screens/superfans/superfans.dart';
import 'package:ikonfetemobile/screens/team/team.dart';
import 'package:ikonfetemobile/zoom_scaffold/zoom_scaffold.dart';
import 'package:meta/meta.dart';

class Menu {
  final List<MenuItem> items;

  Menu({
    this.items,
  });
}

class MenuItem {
  final String id;
  final String title;
  final bool isDefault;

  MenuItem({
    this.id,
    this.title,
    this.isDefault: false,
  });

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  bool operator ==(other) =>
      other is MenuItem && other.id == id && other.title == title;
}

Map<MenuItem, Screen> zoomScaffoldMenuItems({@required bool isArtist}) {
  final menu = <MenuItem, Screen>{};
  menu[MenuItem(id: 'home', title: 'Home', isDefault: true)] =
      homeScreen(isArtist: isArtist);
  menu[MenuItem(id: 'superfans', title: 'Super Fans')] = superfansScreen;

  // artist menu
  if (isArtist) {
    menu[MenuItem(id: 'team', title: 'Team')] = teamScreen;
    menu[MenuItem(id: 'messages', title: 'Messages')] = messagesScreen;
  } else {
    // fan menu
    menu[MenuItem(id: 'ikon', title: 'Ikon')] = ikonScreen;
    menu[MenuItem(id: 'inbox', title: 'Inbox')] = inboxScreen;
  }

  menu[MenuItem(id: 'settings', title: 'Settings')] = settingsScreen;
  return menu;
}

Screen zoomScaffoldScreen(
  String menuItemId, {
  @required bool isArtist,
}) {
  final menuItems = zoomScaffoldMenuItems(isArtist: isArtist);
  var menuItem =
      menuItems.keys.firstWhere((item) => item.id == menuItemId, orElse: null);
  if (menuItem == null) {
    menuItem = menuItems.keys.firstWhere((item) => item.isDefault);
  }
  return menuItems[menuItem];
}

Screen defaultScreen({@required bool isArtist}) {
  final menuItem = defaultMenuItem(isArtist: isArtist);
  return zoomScaffoldMenuItems(isArtist: isArtist)[menuItem];
}

MenuItem defaultMenuItem({@required bool isArtist}) {
  final menuItem = zoomScaffoldMenuItems(isArtist: isArtist)
      .keys
      .firstWhere((item) => item.isDefault);
  if (menuItem == null) throw ArgumentError("Default Menu Item not found");
  return menuItem;
}

Menu zoomScaffoldMenu({@required bool isArtist}) {
  return Menu(items: zoomScaffoldMenuItems(isArtist: isArtist).keys.toList());
}
