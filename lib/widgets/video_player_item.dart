import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import 'package:edutube_shorts/models/video.dart';

/// VideoPlayerItem widget handles the lifecycle of VideoPlayerController
/// This widget is designed for high-performance swiping scenarios
class VideoPlayerItem extends StatefulWidget {
  final Video video;
  final bool isVisible;
  final VoidCallback? onInitialized;

  const VideoPlayerItem({
    super.key,
    required this.video,
    required this.isVisible,
    this.onInitialized,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayer;
  bool _userPausedManually = false; // Track if user explicitly paused

  @override
  void initState() {
    super.initState();

    // Initialize video using cache manager
    _initializeVideoPlayer = _initializeWithCache();
  }

  /// Initialize video from cache or download it
  Future<void> _initializeWithCache() async {
    try {
      // Get the video file from cache (or download if not cached)
      final File videoFile = await DefaultCacheManager().getSingleFile(
        widget.video.url,
      );

      // Initialize controller with the cached file
      _controller = VideoPlayerController.file(videoFile);

      await _controller.initialize();

      if (mounted) {
        setState(() {});
        widget.onInitialized?.call();
        // Auto-play when visible (Instagram-style)
        if (widget.isVisible) {
          _controller.play();
          _userPausedManually = false;
        }
      }
    } catch (error) {
      debugPrint('Error initializing video from cache: $error');
      rethrow;
    }
  }

  @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle visibility changes
    if (widget.isVisible && !oldWidget.isVisible) {
      // Became visible: resume playback (unless user manually paused)
      debugPrint('🎬 Video ${widget.video.id} became visible');
      if (!_userPausedManually) {
        // Small delay to ensure video is ready
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_userPausedManually) {
            _controller.play();
            debugPrint('▶️ Auto-playing ${widget.video.id}');
          }
        });
      }
    } else if (!widget.isVisible && oldWidget.isVisible) {
      // Became hidden: pause playback to save resources
      debugPrint('⏸️ Video ${widget.video.id} became hidden');
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeVideoPlayer,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.black,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(_controller),
                        // Play/pause overlay - only show when user manually paused
                        if (!_controller.value.isPlaying && _userPausedManually)
                          Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: 32,
                              ),
                            ),
                          ),
                        // Video metadata overlay
                        Positioned(
                          bottom: 20,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.video.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              VideoProgressBar(_controller),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }
      },
    );
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _userPausedManually = true; // User explicitly paused
    } else {
      _controller.play();
      _userPausedManually = false; // User resumed, not manual pause anymore
    }
    setState(() {});
  }
}

/// Custom progress bar for video player
class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoProgressBar(this.controller, {super.key});

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  late Duration _displayedDuration;

  @override
  void initState() {
    super.initState();
    _displayedDuration = widget.controller.value.position;
    widget.controller.addListener(_updateDuration);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateDuration);
    super.dispose();
  }

  void _updateDuration() {
    if (mounted) {
      setState(() {
        _displayedDuration = widget.controller.value.position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = _displayedDuration.inSeconds;
    final duration = widget.controller.value.duration.inSeconds;
    final percentage = duration > 0
        ? (position / duration).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 3,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_displayedDuration),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              _formatDuration(widget.controller.value.duration),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
