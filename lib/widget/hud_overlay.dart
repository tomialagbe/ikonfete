import 'package:flutter/material.dart';

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
}
