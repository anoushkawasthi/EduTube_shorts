import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:edutube_shorts/models/video.dart';
import 'package:edutube_shorts/utils/video_cache_manager.dart';
import 'package:edutube_shorts/utils/video_preloader.dart';

class VideoPlayerItem extends StatefulWidget {
  final Video video;
  final bool isVisible;

  const VideoPlayerItem({
    super.key,
    required this.video,
    required this.isVisible,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayer;
  bool _userPausedManually = false;
  bool _showPauseIcon = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer = _initializeWithCache();
  }

  Future<void> _initializeWithCache() async {
    try {
      // Check preloaded controller first
      final preloaded = VideoPreloader.getPreloadedController(widget.video.id);
      if (preloaded != null && preloaded.value.isInitialized) {
        _controller = preloaded;
        _controller!.setLooping(true);
        if (mounted && widget.isVisible) {
          _controller!.play();
        }
        return;
      }

      final cacheManager = VideoCacheManager.instance;
      final fileInfo = await cacheManager.getFileFromCache(widget.video.url);

      if (fileInfo != null) {
        _controller = VideoPlayerController.file(fileInfo.file);
      } else {
        // Download via cache manager first — it handles redirects (e.g. Google Drive)
        // that video_player's network URL can't follow.
        try {
          final downloaded = await cacheManager.downloadFile(widget.video.url);
          _controller = VideoPlayerController.file(downloaded.file);
        } catch (e) {
          debugPrint('⚠️ Cache download failed, trying direct URL: $e');
          _controller = VideoPlayerController.networkUrl(
            Uri.parse(widget.video.url),
          );
        }
      }

      await _controller!.initialize();
      _controller!.setLooping(true);

      if (mounted) {
        setState(() {});
        if (widget.isVisible) {
          _controller!.play();
          _userPausedManually = false;
        }
      }
    } catch (error) {
      debugPrint('Error initializing video: $error');
      rethrow;
    }
  }

  @override
  void didUpdateWidget(VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller == null) return;

    if (widget.isVisible && !oldWidget.isVisible) {
      if (!_userPausedManually) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && !_userPausedManually && _controller != null) {
            _controller!.play();
          }
        });
      }
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    // Only dispose if we own the controller (not preloaded)
    final preloaded = VideoPreloader.getPreloadedController(widget.video.id);
    if (_controller != null && _controller != preloaded) {
      _controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeVideoPlayer,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.done &&
            _controller != null &&
            _controller!.value.isInitialized) {
          return _buildPlayer();
        }

        return _buildLoadingState();
      },
    );
  }

  Widget _buildPlayer() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video — fill viewport width, crop height if needed
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),

            // Pause overlay
            if (_showPauseIcon)
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 150),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

            // Buffering indicator
            ValueListenableBuilder(
              valueListenable: _controller!,
              builder: (context, value, child) {
                if (value.isBuffering) {
                  return const Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white70),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Progress bar
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: VideoProgressBar(_controller!),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: Colors.white38, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Could not load video',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                style: const TextStyle(color: Colors.white30, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _initializeVideoPlayer = _initializeWithCache();
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePlayPause() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    HapticFeedback.lightImpact();
    if (_controller!.value.isPlaying) {
      _controller!.pause();
      _userPausedManually = true;
      setState(() => _showPauseIcon = true);
    } else {
      _controller!.play();
      _userPausedManually = false;
      setState(() => _showPauseIcon = false);
    }
  }
}

/// Seekable progress bar with drag support
class VideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoProgressBar(this.controller, {super.key});

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  Duration _position = Duration.zero;
  bool _isDragging = false;
  double _dragValue = 0;

  @override
  void initState() {
    super.initState();
    _position = widget.controller.value.position;
    widget.controller.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted && !_isDragging) {
      setState(() => _position = widget.controller.value.position);
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = widget.controller.value.duration;
    final durationMs = duration.inMilliseconds.toDouble();
    final progress = _isDragging
        ? _dragValue
        : (durationMs > 0
            ? (_position.inMilliseconds / durationMs).clamp(0.0, 1.0)
            : 0.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seekable slider
        SizedBox(
          height: 20,
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.red,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.25),
              thumbColor: Colors.red,
              overlayColor: Colors.red.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: progress,
              onChangeStart: (val) {
                _isDragging = true;
              },
              onChanged: (val) {
                setState(() => _dragValue = val);
              },
              onChangeEnd: (val) {
                _isDragging = false;
                final seekTo =
                    Duration(milliseconds: (val * durationMs).toInt());
                widget.controller.seekTo(seekTo);
                HapticFeedback.selectionClick();
              },
            ),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fmt(_isDragging
                  ? Duration(milliseconds: (_dragValue * durationMs).toInt())
                  : _position),
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            Text(
              _fmt(duration),
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
