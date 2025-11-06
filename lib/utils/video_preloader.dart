import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:edutube_shorts/models/video.dart';

/// VideoPreloader manages video pre-loading to optimize swipe experience
/// It pre-initializes controllers for next/previous videos so they're ready
/// when the user swipes without blocking the UI
class VideoPreloader {
  static final Map<String, VideoPlayerController> _preloadedControllers = {};
  static final Set<String> _loadingControllers = {};

  /// Pre-initialize a video controller in the background
  /// This allows fast playback when the user swipes to it
  static Future<void> preloadVideo(Video video) async {
    final videoKey = video.id;

    // Skip if already preloaded or currently loading
    if (_preloadedControllers.containsKey(videoKey) ||
        _loadingControllers.contains(videoKey)) {
      return;
    }

    _loadingControllers.add(videoKey);

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(video.url));
      await controller.initialize();
      _preloadedControllers[videoKey] = controller;
    } catch (e) {
      debugPrint('Error preloading video $videoKey: $e');
    } finally {
      _loadingControllers.remove(videoKey);
    }
  }

  /// Get a preloaded controller if available, otherwise return null
  static VideoPlayerController? getPreloadedController(String videoId) {
    return _preloadedControllers[videoId];
  }

  /// Clear a specific preloaded controller to free memory
  static void clearPreloadedController(String videoId) {
    final controller = _preloadedControllers.remove(videoId);
    controller?.dispose();
  }

  /// Clear all preloaded controllers
  static void clearAll() {
    for (var controller in _preloadedControllers.values) {
      controller.dispose();
    }
    _preloadedControllers.clear();
    _loadingControllers.clear();
  }

  /// Get memory stats (for debugging performance)
  static Map<String, dynamic> getStats() {
    return {
      'preloaded': _preloadedControllers.length,
      'loading': _loadingControllers.length,
    };
  }
}
