import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:edutube_shorts/utils/video_source_resolver.dart';

/// Best-effort warmup so the next swipe hits a warm TCP/TLS path (POC).
class VideoConnectionWarmup {
  VideoConnectionWarmup._();

  static final http.Client _client = http.Client();

  /// Fetch the first chunk of the stream; does not block the UI for long.
  static Future<void> warm(String url) async {
    try {
      final uri = VideoSourceResolver.playbackUriCandidates(url).first;
      await _client
          .get(
            uri,
            headers: {
              ...VideoSourceResolver.playbackHttpHeaders,
              'Range': 'bytes=0-262143',
            },
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Ignore — playback still uses its own stack.
    }
  }

  static void warmInBackground(String url) {
    unawaited(warm(url));
  }
}
