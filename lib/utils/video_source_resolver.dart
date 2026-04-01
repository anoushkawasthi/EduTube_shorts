/// Normalizes remote video URLs for streaming (especially Google Drive).
/// Full-file download via cache managers often stores HTML interstitials instead
/// of video bytes; ExoPlayer/AVPlayer stream more reliably from these URLs.
class VideoSourceResolver {
  VideoSourceResolver._();

  static const Map<String, String> playbackHttpHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Accept': '*/*',
  };

  static List<Uri> playbackUriCandidates(String url) {
    final parsed = Uri.parse(url);
    final id = _extractGoogleDriveFileId(parsed);
    final out = <Uri>[];
    final seen = <String>{};

    void addUri(Uri u) {
      final s = u.toString();
      if (seen.add(s)) {
        out.add(u);
      }
    }

    if (id != null && id.isNotEmpty) {
      addUri(
        Uri.parse(
          'https://drive.usercontent.google.com/download?id=$id&export=download',
        ),
      );
      addUri(
        Uri.parse(
          'https://drive.usercontent.google.com/uc?id=$id&export=download',
        ),
      );
      addUri(
        Uri.parse(
          'https://drive.google.com/uc?export=download&id=$id',
        ),
      );
    }
    addUri(parsed);
    return out;
  }

  static String? _extractGoogleDriveFileId(Uri uri) {
    final q = uri.queryParameters['id'];
    if (q != null && q.isNotEmpty) {
      return q;
    }
    final segs = uri.pathSegments;
    final i = segs.indexOf('d');
    if (i != -1 && i + 1 < segs.length) {
      return segs[i + 1];
    }
    return null;
  }
}
