import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ikonfetemobile/colors.dart';
import 'package:video_player/video_player.dart';

class SocialCardVideo extends StatefulWidget {
  final String videoUrl;
  final String placeHolderUrl;
  final Duration videoDuration;

  SocialCardVideo({
    @required this.videoUrl,
    @required this.placeHolderUrl,
    @required this.videoDuration,
  });

  @override
  SocialCardVideoState createState() {
    return new SocialCardVideoState();
  }
}

class SocialCardVideoState extends State<SocialCardVideo> {
  VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.videoUrl,
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: _isPlaying
            ? _VideoContent(_controller)
            : _VideoPlaceHolder(
                _controller,
                widget.placeHolderUrl,
                Duration(minutes: 1, seconds: 30),
              ),
      ),
    );
  }
}

class _VideoContent extends StatelessWidget {
  final VideoPlayerController _controller;

  _VideoContent(this._controller);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Chewie(
          _controller,
          looping: true,
          startAt: Duration.zero,
        ),
      ],
    );
  }
}

class _VideoPlaceHolder extends StatelessWidget {
  final VideoPlayerController _controller;
  final String _placeHolderImageUrl;

  final int _durationMins;
  final int _durationSecs;

  _VideoPlaceHolder(
      this._controller, this._placeHolderImageUrl, Duration videoDuration)
      : _durationSecs = videoDuration.inSeconds > 60
            ? videoDuration.inSeconds % 60
            : videoDuration.inSeconds,
        _durationMins =
            videoDuration.inSeconds > 60 ? videoDuration.inSeconds ~/ 60 : 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          // to be replaced with video
          child: Image.network(
            _placeHolderImageUrl,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Text(
            "$_durationMins:$_durationSecs",
            style: TextStyle(color: Colors.white),
          ),
        ),
        Center(
          child: Container(
            decoration:
                BoxDecoration(color: primaryColor, shape: BoxShape.circle),
            child: CupertinoButton(
              onPressed: () {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              },
              child: Icon(
                Icons.play_arrow,
                size: 30.0,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}
