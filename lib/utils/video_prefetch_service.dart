import 'package:flutter/foundation.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/models/topic.dart';
import 'package:edutube_shorts/utils/video_cache_manager.dart';

/// Central prefetch service — call once at app launch and then on every
/// page change for Instagram-style instant-swipe feel.
class VideoPrefetchService {
  VideoPrefetchService._();

  static final _cache = VideoCacheManager.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // App-level: called from main() after bindings are initialised.
  // Downloads the first video of every topic across all courses so the
  // home-screen → player transition feels instant regardless of which
  // course the user taps.
  // ─────────────────────────────────────────────────────────────────────────
  static void prefetchAppWide() {
    for (final course in CourseData.courses) {
      for (final topic in course.topics) {
        if (topic.videos.isNotEmpty) {
          _bg(topic.videos.first.url);
        }
      }
    }
    debugPrint('🚀 App-wide prefetch triggered for ${CourseData.courses.length} courses');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Course-level: called when PlayerPage opens for a specific course.
  // Downloads video[0] of every topic so every horizontal swipe is cached.
  // ─────────────────────────────────────────────────────────────────────────
  static void prefetchCourse(List<Topic> topics) {
    for (final topic in topics) {
      for (int i = 0; i < topic.videos.length && i < 2; i++) {
        _bg(topic.videos[i].url);
      }
    }
    debugPrint('📦 Course prefetch: ${topics.length} topics');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Position-level: called every time the visible video changes.
  // Caches all 4 neighbours so any next swipe (up/down/left/right) is ready.
  // ─────────────────────────────────────────────────────────────────────────
  static void prefetchAround({
    required List<Topic> topics,
    required int topicIndex,
    required int videoIndex,
  }) {
    final topic = topics[topicIndex];

    // ↓ next video in topic (swipe up)
    if (videoIndex + 1 < topic.videos.length) {
      _bg(topic.videos[videoIndex + 1].url);
    }
    // ↑ prev video in topic (swipe down)
    if (videoIndex - 1 >= 0) {
      _bg(topic.videos[videoIndex - 1].url);
    }
    // → first video of next topic (swipe left)
    if (topicIndex + 1 < topics.length &&
        topics[topicIndex + 1].videos.isNotEmpty) {
      _bg(topics[topicIndex + 1].videos.first.url);
      // Also grab video[1] of next topic if it exists.
      if (topics[topicIndex + 1].videos.length > 1) {
        _bg(topics[topicIndex + 1].videos[1].url);
      }
    }
    // ← first video of prev topic (swipe right)
    if (topicIndex - 1 >= 0 &&
        topics[topicIndex - 1].videos.isNotEmpty) {
      _bg(topics[topicIndex - 1].videos.first.url);
    }
  }

  static void _bg(String url) {
    // ignore errors silently — prefetch is best-effort
    _cache.downloadFile(url).then((_) {}, onError: (_) {});
  }
}
