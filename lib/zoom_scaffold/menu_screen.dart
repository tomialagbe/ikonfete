import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/bloc/application_bloc.dart';
import 'package:ikonfetemobile/bloc/bloc.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/routes.dart';
import 'package:ikonfetemobile/utils/logout_helper.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:ikonfetemobile/zoom_scaffold/menu.dart';
import 'package:transparent_image/transparent_image.dart';

import 'zoom_scaffold.dart';

final menuScreenKey = GlobalKey<_MenuScreenState>(debugLabel: 'MenuScreen');

class MenuScreen extends StatefulWidget {
  final Menu menu;
  final String selectedItemId;
  final Function(String) onMenuItemSelected;

  MenuScreen({
    this.menu,
    this.selectedItemId,
    this.onMenuItemSelected,
  }) : super(key: menuScreenKey);

  @override
  _MenuScreenState createState() => new _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  AnimationController titleAnimationController;
  double selectorYTop;
  double selectorYBottom;

  setSelectedRenderBox(RenderBox newRenderBox) async {
    final newYTop = newRenderBox.localToGlobal(const Offset(0.0, 0.0)).dy;
    final newYBottom = newYTop + newRenderBox.size.height;
    if (newYTop != selectorYTop) {
      selectorYTop = newYTop;
      selectorYBottom = newYBottom;
    }
  }

  @override
  void initState() {
    super.initState();
    titleAnimationController = new AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    titleAnimationController.dispose();
    super.dispose();
  }

  createMenuTitle(MenuController menuController) {
    switch (menuController.state) {
      case MenuState.open:
      case MenuState.opening:
        titleAnimationController.forward();
        break;
      case MenuState.closed:
      case MenuState.closing:
        titleAnimationController.reverse();
        break;
    }

    return new AnimatedBuilder(
        animation: titleAnimationController,
        child: new OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.topLeft,
          child: new Padding(
            padding: const EdgeInsets.all(30.0),
            child: new Text(
              'Menu',
              style: new TextStyle(
                color: const Color(0x88444444),
                fontSize: 240.0,
                fontFamily: 'mermaid',
              ),
              textAlign: TextAlign.left,
              softWrap: false,
            ),
          ),
        ),
        builder: (BuildContext context, Widget child) {
          return new Transform(
            transform: new Matrix4.translationValues(
              250.0 * (1.0 - titleAnimationController.value) - 100.0,
              0.0,
              0.0,
            ),
            child: child,
          );
        });
  }

  Widget createMenuProfileDetails(MenuController menuController) {
    switch (menuController.state) {
      case MenuState.open:
      case MenuState.opening:
        titleAnimationController.forward();
        break;
      case MenuState.closed:
      case MenuState.closing:
        titleAnimationController.reverse();
        break;
    }

    final initState = BlocProvider.of<ApplicationBloc>(context).initState;
    return Transform(
      transform: Matrix4.translationValues(0.0, 100.0, 0.0),
      child: AnimatedOpacity(
        opacity: titleAnimationController.value == 0.0
            ? 0.1
            : titleAnimationController.value,
        duration: Duration(milliseconds: 800),
        child: Column(
          children: <Widget>[
            ListTile(
              dense: false,
              isThreeLine: false,
              onTap: () async {
                // navigate to profile page
                router.navigateTo(
                  context,
                  RouteNames.profile(
                      uid: initState.currentUser.uid,
                      isArtist: initState.isArtist),
                  replace: false,
                  transition: TransitionType.inFromRight,
                );
              },
              leading: CircleAvatar(
                backgroundColor: primaryColor,
                radius: 30.0,
                backgroundImage: !StringUtils.isNullOrEmpty(
                        initState.currentUser.photoUrl)
                    ? CachedNetworkImageProvider(initState.currentUser.photoUrl)
                    : MemoryImage(kTransparentImage),
              ),
              title: Text(
                initState.currentUser.displayName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                initState.currentUser.email,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            // TODO: fete score
            ListTile(
              contentPadding: const EdgeInsets.only(left: 90.0),
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "0",
                    style: TextStyle(fontSize: 50.0, color: Color(0xFFF0F0F0)),
                  ),
                  SizedBox(width: 5.0),
                  Icon(Icons.arrow_upward, color: Colors.green, size: 24.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget createMenuItems(MenuController menuController) {
    final List<Widget> listItems = [];
    final animationIntervalDuration = 0.5;
    final perListItemDelay =
        menuController.state != MenuState.closing ? 0.05 : 0.0;
    for (var i = 0; i < widget.menu.items.length; ++i) {
      final animationIntervalStart = i * perListItemDelay;
      final animationIntervalEnd =
          animationIntervalStart + animationIntervalDuration;
      final isSelected = widget.menu.items[i].id == widget.selectedItemId;

      listItems.add(new AnimatedMenuListItem(
        menuState: menuController.state,
        isSelected: isSelected,
        duration: const Duration(milliseconds: 600),
        curve: new Interval(animationIntervalStart, animationIntervalEnd,
            curve: Curves.easeOut),
        menuListItem: new _MenuListItem(
          title: widget.menu.items[i].title,
          isSelected: isSelected,
          onTap: () {
            widget.onMenuItemSelected(widget.menu.items[i].id);
            menuController.close();
          },
        ),
      ));
    }

    return new Transform(
      transform: new Matrix4.translationValues(
        0.0,
        240.0,
        0.0,
      ),
      child: Column(
        children: listItems,
      ),
    );
  }

  Widget createLogoutMenuItem(MenuController menuController) {
    final appBloc = BlocProvider.of<ApplicationBloc>(context);
    return Positioned(
      bottom: 30.0,
      left: 35.0,
      child: AnimatedOpacity(
        opacity: titleAnimationController.value,
        duration: Duration(milliseconds: 800),
        child: GestureDetector(
          onTap: () async {
            if (await canLogout(context)) {
              if (await appBloc.doLogout()) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  router.navigateTo(
                    context,
                    RouteNames.login(isArtist: appBloc.initState.isArtist),
                    transition: TransitionType.inFromLeft,
                    replace: true,
                  );
                }
              }
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(FontAwesome5Icons.powerOff, color: primaryColor),
              SizedBox(width: 10.0),
              Text(
                "Logout",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18.0,
                  fontFamily: 'SanFranciscoDisplay',
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ZoomScaffoldMenuController(
        builder: (BuildContext context, MenuController menuController) {
      var shouldRenderSelector = true;
      var actualSelectorYTop = selectorYTop;
      var actualSelectorYBottom = selectorYBottom;
      var selectorOpacity = 1.0;

      if (menuController.state == MenuState.closed ||
          menuController.state == MenuState.closing ||
          selectorYTop == null) {
        final RenderBox menuScreenRenderBox =
            context.findRenderObject() as RenderBox;

        if (menuScreenRenderBox != null) {
          final menuScreenHeight = menuScreenRenderBox.size.height;
          actualSelectorYTop = menuScreenHeight - 50.0;
          actualSelectorYBottom = menuScreenHeight;
          selectorOpacity = 0.0;
        } else {
          shouldRenderSelector = false;
        }
      }

      return new Container(
        width: double.infinity,
        height: double.infinity,
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage('assets/images/dark_grunge_bk.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: new Material(
          color: Colors.transparent,
          child: new Stack(
            children: [
//              createMenuTitle(menuController),
              createMenuItems(menuController),
              createMenuProfileDetails(menuController),
              createLogoutMenuItem(menuController),
              shouldRenderSelector
                  ? new ItemSelector(
                      topY: actualSelectorYTop,
                      bottomY: actualSelectorYBottom,
                      opacity: selectorOpacity,
                    )
                  : new Container(),
            ],
          ),
        ),
      );
    });
  }
}

class ItemSelector extends ImplicitlyAnimatedWidget {
  final double topY;
  final double bottomY;
  final double opacity;

  ItemSelector({
    this.topY,
    this.bottomY,
    this.opacity,
  }) : super(duration: const Duration(milliseconds: 250));

  @override
  _ItemSelectorState createState() => new _ItemSelectorState();
}

class _ItemSelectorState extends AnimatedWidgetBaseState<ItemSelector> {
  Tween<double> _topY;
  Tween<double> _bottomY;
  Tween<double> _opacity;

  @override
  void forEachTween(TweenVisitor visitor) {
    _topY = visitor(
      _topY,
      widget.topY,
      (dynamic value) => new Tween<double>(begin: value),
    );
    _bottomY = visitor(
      _bottomY,
      widget.bottomY,
      (dynamic value) => new Tween<double>(begin: value),
    );
    _opacity = visitor(
      _opacity,
      widget.opacity,
      (dynamic value) => new Tween<double>(begin: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Positioned(
      top: _topY.evaluate(animation),
      child: new Opacity(
        opacity: _opacity.evaluate(animation),
        child: new Container(
          width: 5.0,
          height: _bottomY.evaluate(animation) - _topY.evaluate(animation),
          color: primaryColor,
        ),
      ),
    );
  }
}

class AnimatedMenuListItem extends ImplicitlyAnimatedWidget {
  final _MenuListItem menuListItem;
  final MenuState menuState;
  final bool isSelected;
  final Duration duration;

  AnimatedMenuListItem({
    this.menuListItem,
    this.menuState,
    this.isSelected,
    this.duration,
    curve,
  }) : super(duration: duration, curve: curve);

  @override
  _AnimatedMenuListItemState createState() => new _AnimatedMenuListItemState();
}

class _AnimatedMenuListItemState
    extends AnimatedWidgetBaseState<AnimatedMenuListItem> {
  final double closedSlidePosition = 200.0;
  final double openSlidePosition = 0.0;

  Tween<double> _translation;
  Tween<double> _opacity;

  updateSelectedRenderBox() {
    final renderBox = context.findRenderObject() as RenderBox;
    if (renderBox != null && widget.isSelected) {
      (menuScreenKey.currentState).setSelectedRenderBox(renderBox);
    }
  }

  @override
  void forEachTween(TweenVisitor visitor) {
    var slide, opacity;

    switch (widget.menuState) {
      case MenuState.closed:
      case MenuState.closing:
        slide = closedSlidePosition;
        opacity = 0.0;
        break;
      case MenuState.open:
      case MenuState.opening:
        slide = openSlidePosition;
        opacity = 1.0;
        break;
    }

    _translation = visitor(
      _translation,
      slide,
      (dynamic value) => new Tween<double>(begin: value),
    );

    _opacity = visitor(
      _opacity,
      opacity,
      (dynamic value) => new Tween<double>(begin: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    updateSelectedRenderBox();

    return new Opacity(
      opacity: _opacity.evaluate(animation),
      child: new Transform(
        transform: new Matrix4.translationValues(
          0.0,
          _translation.evaluate(animation),
          0.0,
        ),
        child: widget.menuListItem,
      ),
    );
  }
}

class _MenuListItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function() onTap;

  _MenuListItem({
    this.title,
    this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      splashColor: const Color(0x44000000),
      onTap: isSelected ? null : onTap,
      child: Container(
        width: double.infinity,
        child: new Padding(
          padding: const EdgeInsets.only(left: 35.0, top: 15.0, bottom: 15.0),
          child: new Text(
            title,
            style: new TextStyle(
              color: isSelected ? primaryColor : Colors.white,
              fontSize: 18.0,
              fontFamily: 'SanFranciscoDisplay',
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
