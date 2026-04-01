import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/models/video.dart';

/// Singleton service for managing liked and saved video state across the app.
/// State persists across app restarts via SharedPreferences.
class VideoStateService extends ChangeNotifier {
  VideoStateService._();
  static final VideoStateService instance = VideoStateService._();

  static const _likedKey = 'liked_video_ids';
  static const _savedKey = 'saved_video_ids';

  final Set<String> _likedVideoIds = {};
  final Set<String> _savedVideoIds = {};
  bool _loaded = false;

  /// Must be called once at app startup (e.g. in main()).
  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _likedVideoIds.addAll(prefs.getStringList(_likedKey) ?? []);
    _savedVideoIds.addAll(prefs.getStringList(_savedKey) ?? []);
    _loaded = true;
    notifyListeners();
  }

  // ─── Liked ───
  Set<String> get likedVideoIds => Set.unmodifiable(_likedVideoIds);
  bool isLiked(String videoId) => _likedVideoIds.contains(videoId);

  void toggleLike(String videoId) {
    if (_likedVideoIds.contains(videoId)) {
      _likedVideoIds.remove(videoId);
    } else {
      _likedVideoIds.add(videoId);
    }
    _persist(_likedKey, _likedVideoIds);
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
    _persist(_savedKey, _savedVideoIds);
    notifyListeners();
  }

  Future<void> _persist(String key, Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, ids.toList());
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
