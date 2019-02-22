import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FullScreenGif extends StatefulWidget {
  final String placeHolderUrl;
  final String gifUrl;
  final double aspectRatio;

  FullScreenGif({
    @required this.placeHolderUrl,
    @required this.gifUrl,
    @required this.aspectRatio,
  });

  @override
  _FullScreenGifState createState() => _FullScreenGifState();
}

class _FullScreenGifState extends State<FullScreenGif> {
  VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(
      widget.gifUrl,
    )
      ..addListener(() {
        final bool isPlaying = _controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      })
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[],
      ),
      body: Container(
        color: Colors.transparent,
        child: Chewie(
          _controller,
          showControls: false,
          aspectRatio: widget.aspectRatio,
          looping: true,
          placeholder: Image.network(widget.placeHolderUrl),
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
