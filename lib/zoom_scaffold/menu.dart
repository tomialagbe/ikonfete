import 'package:ikonfetemobile/screens/home/home.dart';
import 'package:ikonfetemobile/screens/settings/settings.dart';
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
  return <MenuItem, Screen>{
    MenuItem(id: 'home', title: 'Home', isDefault: true):
        homeScreen(isArtist: isArtist),
    MenuItem(id: 'my_music', title: 'My Music'): null,
    MenuItem(id: 'notifications', title: 'Notifications'): null,
    MenuItem(id: 'recommendations', title: 'Recommendations'): null,
    MenuItem(id: 'events', title: 'Events'): null,
    MenuItem(id: 'settings', title: 'Settings'): settingsScreen(),
  };
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
