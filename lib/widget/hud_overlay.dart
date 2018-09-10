import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart' as colors;
import 'package:ikonfetemobile/icons.dart';
import 'package:progress_indicators/progress_indicators.dart';

class HudOverlay {
  OverlayEntry overlayEntry;

  HudOverlay._internal(this.overlayEntry);

  static HudOverlay show(
      BuildContext context, Widget child, Color overlayColor) {
    final overlayState = Overlay.of(context);
    final entry = OverlayEntry(builder: (_) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              color: overlayColor,
            ),
            child,
          ],
        ),
      );
    });
    overlayState.insert(entry);
    return HudOverlay._internal(entry);
  }

  void close() {
    overlayEntry?.remove();
  }

  static Color defaultColor() => Colors.white.withOpacity(0.7);

  static Widget dotsLoadingIndicator() {
    return Center(
      child: CollectionSlideTransition(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              FontAwesome5Icons.solidCircle,
              size: 15.0,
              color: colors.primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              FontAwesome5Icons.solidCircle,
              size: 15.0,
              color: colors.primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Icon(
              FontAwesome5Icons.solidCircle,
              size: 15.0,
              color: colors.primaryColor,
            ),
          ),
          Icon(
            FontAwesome5Icons.solidCircle,
            size: 15.0,
            color: colors.primaryColor,
          ),
        ],
      ),
    );
  }
}
