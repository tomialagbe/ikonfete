import 'package:ikonfetemobile/screens/home/home.dart';
import 'package:ikonfetemobile/screens/ikonscreen/ikon_screen.dart';
import 'package:ikonfetemobile/screens/messaging/messaging.dart';
import 'package:ikonfetemobile/screens/music/music.dart';
import 'package:ikonfetemobile/screens/profile/profile_screen.dart';
import 'package:ikonfetemobile/screens/settings/settings_screen.dart';
import 'package:ikonfetemobile/screens/superfans/superfans.dart';
import 'package:ikonfetemobile/screens/team/team.dart';
import 'package:ikonfetemobile/zoom_scaffold/menu_ids.dart';
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
  final bool display;

  MenuItem({
    this.id,
    this.title,
    this.isDefault: false,
    this.display: true,
  });

  @override
  int get hashCode => id.hashCode ^ title.hashCode;

  @override
  bool operator ==(other) =>
      other is MenuItem && other.id == id && other.title == title;
}

Map<MenuItem, Screen> zoomScaffoldMenuItems({@required bool isArtist}) {
  final menu = <MenuItem, Screen>{};

  menu[MenuItem(id: MenuIDs.profile, title: 'Profile', display: false)] =
      profileScreen;

  menu[MenuItem(id: MenuIDs.home, title: 'Home', isDefault: true)] =
      homeScreen();
  menu[MenuItem(id: MenuIDs.superFans, title: 'Super Fans')] = superfansScreen;

  if (isArtist) {
    menu[MenuItem(id: MenuIDs.team, title: 'Team')] = teamScreen;
//    menu[MenuItem(id: MenuIDs.inbox, title: 'Inbox')] = inboxScreen;
  } else {
    // fan menu
    menu[MenuItem(id: MenuIDs.ikon, title: 'Ikon')] = ikonScreen;
//    menu[MenuItem(id: MenuIDs.messages, title: 'Messages')] = messagesScreen;
  }

  menu[MenuItem(id: MenuIDs.music, title: 'Music')] = musicScreen;
  menu[MenuItem(id: MenuIDs.messaging, title: 'Messaging')] = messagingScreen;
  menu[MenuItem(id: MenuIDs.settings, title: 'Settings')] = settingsScreen;
  return menu;
}

Screen getZoomScaffoldScreen(String menuItemId, {@required bool isArtist}) {
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

//MenuItem defaultMenuItem({@required bool isArtist}) {
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
