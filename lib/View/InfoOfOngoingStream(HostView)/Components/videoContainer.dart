import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:cratch/widgets/custom_icon_button.dart';
import 'package:video_player/video_player.dart';
import '../../../Utils/color_constant.dart';
import '../../../Utils/image_constant.dart';

class VideoContainer extends StatefulWidget {
  final String liveUrl;

  const VideoContainer({Key? key, required this.liveUrl}) : super(key: key);

  @override
  _VideoContainerState createState() => _VideoContainerState();
}

class _VideoContainerState extends State<VideoContainer> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  bool _isStreamActive = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(widget.liveUrl);
  }

  Future<void> _initializeVideoPlayer(String path) async {
    try {
      _videoPlayerController = VideoPlayerController.network(path);
      await _videoPlayerController.initialize();

      setState(() {
        _isStreamActive = _videoPlayerController.value.isInitialized;
        if (_isStreamActive) {
          _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController,
              autoPlay: true,
              looping: false,
              aspectRatio: 16 / 9
              // other customization options
              );
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing ChewieController: $e');
      // Handle the error gracefully, e.g., show an error message or fallback UI
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.pause(); // Pause the video playback
    _videoPlayerController.pause(); // Pause the video playback
    _chewieController.dispose(); // Dispose of the Chewie controller
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 169,
      // margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Stack(
          children: [
            _isStreamActive
                ? Container(
                    width: double
                        .infinity, // Set the width to take up the full available space
                    child: AspectRatio(
                      aspectRatio: 16 /
                          9, // Replace with the correct aspect ratio of the video
                      child: Chewie(
                        controller: _chewieController,
                      ),
                    ),
                  )
                : Image.asset(
                    AppImages.fortnite,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: 169,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.4),
                      AppColors.black.withOpacity(0.5),
                      AppColors.black.withOpacity(0.6),
                      AppColors.black.withOpacity(0.7),
                      AppColors.black,
                    ])),
              ),
            ),
            _isStreamActive
                ? const Center()
                : Align(
                    alignment: Alignment.center,
                    child: IconButtonWidget(
                      ontap: () {},
                      height: 60,
                      width: 60,
                      containerColor: AppColors.blue.withOpacity(0.9),
                      widget: Icon(Icons.play_arrow_rounded,
                          color: AppColors.whiteA700, size: 45),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
