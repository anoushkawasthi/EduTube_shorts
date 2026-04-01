import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:edutube_shorts/models/video.dart';
import 'package:edutube_shorts/theme/theme.dart';
import 'package:edutube_shorts/utils/video_source_resolver.dart';

/// VideoPlayerItem widget handles the lifecycle of VideoPlayerController
/// This widget is designed for high-performance swiping scenarios
class VideoPlayerItem extends StatefulWidget {
  final Video video;
  final bool isVisible;
  final VoidCallback? onInitialized;
  final Function(bool isPlaying)? onPlayingStateChanged;

  const VideoPlayerItem({
    super.key,
    required this.video,
    required this.isVisible,
    this.onInitialized,
    this.onPlayingStateChanged,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayer;
  bool _userPausedManually = false; // Track if user explicitly paused

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer = _initializeNetwork();
  }

  /// Stream from network with Drive-friendly URL fallbacks (no full download first).
  Future<void> _initializeNetwork() async {
    final candidates = VideoSourceResolver.playbackUriCandidates(widget.video.url);
    Object? lastError;

    for (final uri in candidates) {
      VideoPlayerController? c;
      try {
        c = VideoPlayerController.networkUrl(
          uri,
          httpHeaders: VideoSourceResolver.playbackHttpHeaders,
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        );
        await c.initialize();
        _controller = c;
        c = null;

        if (mounted) {
          setState(() {});
          widget.onInitialized?.call();
          if (widget.isVisible) {
            _controller!.play();
            _userPausedManually = false;
          }
        }
        return;
      } catch (e, _) {
        lastError = e;
        debugPrint('Video init failed for $uri: $e');
        await c?.dispose();
      }
    }

    throw lastError ?? Exception('No playback URL worked');
  }

  @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    final ctrl = _controller;
    if (ctrl == null) {
      return;
    }

    // Handle visibility changes
    if (widget.isVisible && !oldWidget.isVisible) {
      debugPrint('🎬 Video ${widget.video.id} became visible');
      if (!_userPausedManually) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_userPausedManually && _controller != null) {
            _controller!.play();
            debugPrint('▶️ Auto-playing ${widget.video.id}');
          }
        });
      }
    } else if (!widget.isVisible && oldWidget.isVisible) {
      debugPrint('⏸️ Video ${widget.video.id} became hidden');
      ctrl.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeVideoPlayer,
      builder: (context, snapshot) {
        final ctrl = _controller;
        if (snapshot.connectionState == ConnectionState.done && ctrl != null) {
          return GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              color: Colors.black,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: ctrl.value.size.width,
                    height: ctrl.value.size.height,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(ctrl),
                        // Play/pause overlay - only show when user manually paused
                        if (!ctrl.value.isPlaying && _userPausedManually)
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
                        // Video progress bar overlay
                        Positioned(
                          bottom: 20,
                          left: 16,
                          right: 16,
                          child: VideoProgressBar(ctrl),
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
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
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
    final ctrl = _controller;
    if (ctrl == null) {
      return;
    }
    if (ctrl.value.isPlaying) {
      ctrl.pause();
      _userPausedManually = true; // User explicitly paused
      widget.onPlayingStateChanged?.call(false);
    } else {
      ctrl.play();
      _userPausedManually = false; // User resumed, not manual pause anymore
      widget.onPlayingStateChanged?.call(true);
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
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
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
