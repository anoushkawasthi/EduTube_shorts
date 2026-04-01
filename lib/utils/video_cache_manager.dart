import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom CacheManager tuned for video files.
/// - Larger cache (500MB) since videos are large
/// - Longer stale period (30 days) so cached videos persist
/// - Allows more simultaneous downloads for preloading
class VideoCacheManager {
  static const key = 'edutube_video_cache';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
