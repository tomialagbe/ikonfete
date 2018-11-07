import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:ikonfetemobile/icons.dart';
import 'package:ikonfetemobile/utils/strings.dart';
import 'package:transparent_image/transparent_image.dart';

class ArtistProfileHeader implements SliverPersistentHeaderDelegate {
  double minExtent;
  double maxExtent;
  FloatingHeaderSnapConfiguration config;
  Function(double) onScroll;
  Function(bool) onScrollToTop;
  final String artistName;
  final int artistScore;
  final String headerImageUrl;
  final VoidCallback onBackPressed;
  final int numFollowers;
  VoidCallback streamActionHandler;
  VoidCallback messageActionHandler;
  VoidCallback playActionHandler;

  ArtistProfileHeader({
    this.minExtent,
    this.maxExtent,
    this.config,
    this.onScroll,
    this.onScrollToTop,
    @required this.artistName,
    @required this.artistScore,
    this.headerImageUrl,
    this.onBackPressed,
    @required this.numFollowers,
    this.streamActionHandler,
    this.messageActionHandler,
    this.playActionHandler,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    //IF SCROLLED TO TOP
    bool _isScrolledToTop() =>
        (maxExtent - minExtent).toInt() == shrinkOffset.toInt();

    //CALLBACKs
    onScroll(shrinkOffset);
    onScrollToTop(_isScrolledToTop());

    return Stack(
      overflow: Overflow.visible,
      fit: StackFit.expand,
      children: [
        //REPLACE WITH NETWORK IMAGE FOR ARTIST
        Positioned(
          bottom: 60.0,
          left: 0.0,
          right: 0.0,
          child: StringUtils.isNullOrEmpty(headerImageUrl)
              ? Image.memory(kTransparentImage)
              : FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: headerImageUrl,
                  fit: BoxFit.cover,
                ),
        ),

        //OVERLAY GRADIENT
        Positioned(
          bottom: 60.0,
          left: 0.0,
          right: 0.0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black54,
                ],
                stops: [0.5, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                tileMode: TileMode.repeated,
              ),
            ),
          ),
        ),

        //BG PICTURE BLUR
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: shrinkOffset / 12.0,
            sigmaY: shrinkOffset / 12.0,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.transparent,
          ),
        ),

        _buildTitleAndScore(context, shrinkOffset), // TITLE & SCORE
        _buildRedboxContainer(context, shrinkOffset),

        //PINNED APPbAR
//        SafeArea(
//          child: AppBar(
//            backgroundColor: Colors.transparent,
//            leading: IconButton(
//              icon: Icon(CupertinoIcons.back),
//              onPressed: onBackPressed,
//            ),
//            elevation: 0.0,
//            actions: <Widget>[
//              Padding(
//                padding: EdgeInsets.only(right: 20.0),
//                child: Icon(Icons.more_vert),
//              ),
//            ],
//            centerTitle: true,
//            title: Opacity(
//              opacity: _fadeIn(shrinkOffset, context),
//              child: Text(
//                artistName,
//                style: TextStyle(
//                  fontSize: 20.0,
//                ),
//              ),
//            ),
//          ),
//            ),
      ],
    );
  }

  double _fadeOut(double shrinkOffset, BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    double _opacity = -(shrinkOffset / (screenHeight / 4.55)) + 1.0;
    //if scrolled to top
    if ((maxExtent - minExtent).toInt() == shrinkOffset.toInt()) return 0.0;
    return (_opacity < 0 ? 0.0 : _opacity.toDouble()) ?? 1.0;
  }

  double _fadeIn(double shrinkOffset, BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    if (shrinkOffset < screenHeight / 6.0) return 0.0;
    double _opacity = shrinkOffset / (screenHeight / 3.7);
    return (_opacity > 1 ? 1.0 : _opacity.toDouble()) ?? 1.0;
  }

  Widget _buildTitleAndScore(BuildContext context, double shrinkOffset) {
    return Positioned(
      left: 25.0,
      right: 25.0,
      bottom: 100.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Opacity(
          opacity: _fadeOut(shrinkOffset, context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 118.0,
                child: Text(
                  artistName, // ARTIST NAME
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 30.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(width: 3.0, color: Colors.white),
                    bottom: BorderSide(width: 3.0, color: Colors.white),
                  ),
                ),
                child: Text(
                  // ARTIST SCORE
                  artistScore.toString(),
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRedboxContainer(BuildContext context, double shrinkOffset) {
    return Positioned(
      bottom: 0.0,
      left: 25.0,
      width: MediaQuery.of(context).size.width - 50.0,
      child: Opacity(
        opacity: _fadeOut(shrinkOffset, context),
        child: Container(
//          height: 102.0,
          height: 82.0,
          padding: EdgeInsets.symmetric(horizontal: 25.0),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  text: "$numFollowers\n",
                  style: TextStyle(fontSize: 20.0),
                  children: [
                    TextSpan(
                      text: 'Following',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.white.withOpacity(0.64),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 16.0),
                    height: 48.0,
                    width: 48.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: IconButton(
                      iconSize: 20.0,
                      alignment: Alignment.center,
                      icon: Icon(
                        FontAwesome5Icons.stream,
                        color: Colors.white,
                      ),
                      onPressed: streamActionHandler,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 16.0),
                    height: 48.0,
                    width: 48.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: IconButton(
                      iconSize: 20.0,
                      alignment: Alignment.center,
                      icon: Icon(
                        FontAwesome5Icons.comment,
                        color: Colors.white,
                      ),
                      onPressed: messageActionHandler,
                    ),
                  ),
                  Container(
                    height: 48.0,
                    width: 48.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: IconButton(
                      iconSize: 20.0,
                      alignment: Alignment.center,
                      icon: Icon(
                        FontAwesome5Icons.play,
                        color: Colors.white,
                      ),
                      onPressed: playActionHandler,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration => config ?? null;
}
