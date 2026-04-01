import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:edutube_shorts/models/video.dart';
import 'package:edutube_shorts/utils/video_source_resolver.dart';

/// Optional background pre-initialization (same URL stack as [VideoPlayerItem]).
class VideoPreloader {
  static final Map<String, VideoPlayerController> _preloadedControllers = {};
  static final Set<String> _loadingControllers = {};

  static Future<void> preloadVideo(Video video) async {
    final videoKey = video.id;

    if (_preloadedControllers.containsKey(videoKey) ||
        _loadingControllers.contains(videoKey)) {
      return;
    }

    _loadingControllers.add(videoKey);

    try {
      final uri = VideoSourceResolver.playbackUriCandidates(video.url).first;
      final controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: VideoSourceResolver.playbackHttpHeaders,
      );
      await controller.initialize();
      _preloadedControllers[videoKey] = controller;
    } catch (e) {
      debugPrint('Error preloading video $videoKey: $e');
    } finally {
      _loadingControllers.remove(videoKey);
    }
  }

  static VideoPlayerController? getPreloadedController(String videoId) {
    return _preloadedControllers[videoId];
  }

  static void clearPreloadedController(String videoId) {
    final controller = _preloadedControllers.remove(videoId);
    controller?.dispose();
  }

  static void clearAll() {
    for (var controller in _preloadedControllers.values) {
      controller.dispose();
    }
    _preloadedControllers.clear();
    _loadingControllers.clear();
  }

  static Map<String, dynamic> getStats() {
    return {
      'preloaded': _preloadedControllers.length,
      'loading': _loadingControllers.length,
    };
  }
}
