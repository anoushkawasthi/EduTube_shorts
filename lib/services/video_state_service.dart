import 'package:flutter/foundation.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/models/video.dart';

/// Singleton service for managing liked and saved video state across the app.
class VideoStateService extends ChangeNotifier {
  VideoStateService._();
  static final VideoStateService instance = VideoStateService._();

  final Set<String> _likedVideoIds = {};
  final Set<String> _savedVideoIds = {};

  // ─── Liked ───
  Set<String> get likedVideoIds => Set.unmodifiable(_likedVideoIds);
  bool isLiked(String videoId) => _likedVideoIds.contains(videoId);

  void toggleLike(String videoId) {
    if (_likedVideoIds.contains(videoId)) {
      _likedVideoIds.remove(videoId);
    } else {
      _likedVideoIds.add(videoId);
    }
    notifyListeners();
  }

  // ─── Saved ───
  Set<String> get savedVideoIds => Set.unmodifiable(_savedVideoIds);
  bool isSaved(String videoId) => _savedVideoIds.contains(videoId);

  void toggleSave(String videoId) {
    if (_savedVideoIds.contains(videoId)) {
      _savedVideoIds.remove(videoId);
    } else {
      _savedVideoIds.add(videoId);
    }
    notifyListeners();
  }

  /// Resolve a set of video IDs into Video objects by searching all courses.
  List<Video> resolveVideos(Set<String> ids) {
    final List<Video> result = [];
    for (final course in CourseData.courses) {
      for (final topic in course.topics) {
        for (final video in topic.videos) {
          if (ids.contains(video.id)) {
            result.add(video);
          }
        }
      }
    }
    return result;
  }

  List<Video> get likedVideos => resolveVideos(_likedVideoIds);
  List<Video> get savedVideos => resolveVideos(_savedVideoIds);
}
