import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../res/image_library.dart';

class HomeTopVideo extends StatefulWidget {
  final bool isTablet;
  final String video;

  const HomeTopVideo(
      {super.key, required this.isTablet, this.video = ImageLibrary.officialHomeVideo});

  @override
  State<HomeTopVideo> createState() => _HomeTopVideoState();
}

class _HomeTopVideoState extends State<HomeTopVideo> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video))
      ..setLooping(true)
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller?.play();
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.isTablet ? 28 : 0)),
        child: Image.asset(
          widget.isTablet ? ImageLibrary.homeBestOfferTablet : ImageLibrary.homeBestOffer,
          width: widget.isTablet ? 320 : double.infinity,
          fit: BoxFit.contain,
        ),
      );
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(widget.isTablet ? 28 : 0)),
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      ),
    );
  }
}