import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/model/social_feed_item.dart';
import 'package:ikonfetemobile/screens/photo_gallery.dart';

class SocialCardImage extends StatelessWidget {
  final SocialFeedItem feedItem;

  SocialCardImage({@required this.feedItem});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: feedItem.images.length >= 3
          ? _buildThreeOrMoreImages(context)
          : (feedItem.images.length == 2
              ? _buildTwoImages(context)
              : _buildOneImage(context)),
    );
  }

  Widget _buildOneImage(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageGallery(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: 300.0),
          child: Image.network(
            feedItem.images[0].fullImage,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTwoImages(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageGallery(context),
      child: Container(
        constraints: BoxConstraints(maxHeight: 300.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0)),
                child: Container(
                  height: double.infinity,
                  child: Image.network(
                    feedItem.images[0].displayImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
//            SizedBox(width: 5.0),
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0)),
                child: Container(
                  child: Image.network(
                    feedItem.images[1].displayImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeOrMoreImages(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageGallery(context),
      child: Container(
        constraints: BoxConstraints(maxHeight: 300.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0)),
                      child: Container(
                        child: Image.network(
                          feedItem.images[0].displayImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.0),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        child: Image.network(
                          feedItem.images[1].displayImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(5.0),
                      ),
                      child: Container(
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image.asset(
                              feedItem.images[2].displayImage,
                              fit: BoxFit.cover,
                            ),
                            feedItem.images.length > 3
                                ? Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: primaryColor.withOpacity(0.4),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(Icons.add, color: Colors.white),
                                        SizedBox(height: 5.0),
                                        Text(
                                            "${feedItem.images.length - 3} more",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageGallery(BuildContext context) {
    final uriList = feedItem.images.map((i) => i.fullImage).toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PhotoGalleryScreen(networkImages: uriList),
      ),
    );
  }
}
