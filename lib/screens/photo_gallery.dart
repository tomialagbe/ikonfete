import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoGalleryScreen extends StatelessWidget {
  final List<String> networkImages;

  PhotoGalleryScreen({@required this.networkImages});

  @override
  Widget build(BuildContext context) {
    final pageOptions = <PhotoViewGalleryPageOptions>[];
    for (String imageUri in networkImages) {
      final opt = PhotoViewGalleryPageOptions(
        imageProvider: CachedNetworkImageProvider(imageUri),
        heroTag: imageUri,
      );
      pageOptions.add(opt);
    }

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[],
      ),
      body: PhotoViewGallery(
        pageOptions: pageOptions,
        backgroundDecoration: BoxDecoration(color: Colors.transparent),
      ),
    );
  }
}
