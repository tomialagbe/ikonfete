import 'dart:async';

import 'package:flutter/material.dart';

class Modal {
  OverlayEntry backgroundEntry;
  OverlayEntry contentEntry;

  Modal._internal(this.backgroundEntry, this.contentEntry);

  static Modal showModal({
    BuildContext context,
    Widget child,
    double widthRatio: 0.8,
    double heightRatio: 0.5,
    Color overlayColor: const Color(0x77000000),
    Color contentBackgroundColor: Colors.white,
    BorderRadius borderRadius,
    EdgeInsets padding: const EdgeInsets.all(10.0),
  }) {
    final screenSize = MediaQuery.of(context).size;
    final maxHeight = heightRatio * screenSize.height;
    final maxWidth = widthRatio * screenSize.width;
    final overlayState = Overlay.of(context);
    final backgroundEntry = OverlayEntry(builder: (_) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: overlayColor,
      );
    });

    final contentEntry = OverlayEntry(builder: (_) {
      return Positioned(
        left: (screenSize.width - maxWidth) / 2,
        width: maxWidth,
        top: (screenSize.height - maxHeight) / 2,
        height: maxHeight,
        child: Theme(
          data: Theme.of(context).copyWith(),
          child: Container(
            decoration: BoxDecoration(
              color: contentBackgroundColor,
              borderRadius: borderRadius ?? BorderRadius.circular(10.0),
            ),
            padding: padding,
            child: child,
          ),
        ),
      );
    });
    overlayState.insert(backgroundEntry);
    overlayState.insert(contentEntry);
    return Modal._internal(backgroundEntry, contentEntry);
  }

  void close() {
    contentEntry?.remove();
    backgroundEntry?.remove();
  }
}

Future<T> showModal<T>({
  @required BuildContext context,
  @required ModalChild<T> child,
  double widthPercent: 0.8,
  double heightPercent: 0.5,
  Color contentBackgroundColor: Colors.white,
  BorderRadius borderRadius,
  EdgeInsets padding: const EdgeInsets.all(10.0),
}) {
  final completer = Completer<T>();
  final modal = Modal.showModal(
    context: context,
    child: child.builder(context, child),
    widthRatio: widthPercent,
    heightRatio: heightPercent,
    borderRadius: borderRadius,
    padding: padding,
  );
  child.onResult.listen((T result) {
    modal.close();
    completer.complete(result);
  });
  return completer.future;
}

typedef Widget ModalChildBuilder<T>(BuildContext context, ModalChild parent);

class ModalChild<T> {
  StreamController<T> _resultStreamController = StreamController.broadcast<T>();

  Stream<T> get onResult => _resultStreamController.stream;

  final ModalChildBuilder builder;

  ModalChild({@required this.builder});

  void dispose() {
    _resultStreamController.close();
  }

  void addResult(T result) {
    _resultStreamController.add(result);
  }
}
