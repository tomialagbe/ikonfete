import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/screens/home/widgets/full_screen_gif.dart';
import 'package:video_player/video_player.dart';

class TwitterGif extends StatefulWidget {
  final String placeHolderUrl;
  final String gifUrl;
  final double aspectRatio;

  TwitterGif({
    @required this.placeHolderUrl,
    @required this.gifUrl,
    @required this.aspectRatio,
  });

  @override
  _TwitterGifState createState() => _TwitterGifState();
}

class _TwitterGifState extends State<TwitterGif> {
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
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: GestureDetector(
        onDoubleTap: _showFullscreenGif,
        child: Stack(
          children: <Widget>[
            Chewie(
              _controller,
              showControls: false,
              aspectRatio: widget.aspectRatio,
              looping: true,
              placeholder: Image.network(widget.placeHolderUrl),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                color: Colors.black45,
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: Text(
                  "GIF",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white70),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showFullscreenGif() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => FullScreenGif(
              placeHolderUrl: widget.placeHolderUrl,
              gifUrl: widget.gifUrl,
              aspectRatio: widget.aspectRatio,
            ),
      ),
    );
  }
}
