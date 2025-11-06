/// Video Integration Example
///
/// This file shows how to fetch videos from the backend API
/// and use them with your existing VideoPlayerItem widget
///
/// Integration Steps:
/// 1. Add 'http' package to pubspec.yaml: http: ^1.1.0
/// 2. Copy this file to your project
/// 3. Use VideoListScreen or adapt the pattern for your needs
library;

import 'package:flutter/material.dart';
import 'package:edutube_shorts/services/video_service.dart';
import 'package:edutube_shorts/models/video.dart';
import 'package:edutube_shorts/widgets/video_player_item.dart';

/// Main screen to display converted videos from backend
class VideoListScreen extends StatefulWidget {
  /// Backend API base URL (e.g., 'http://localhost:3000' or 'https://api.edutube.com')
  final String apiBaseUrl;

  const VideoListScreen({super.key, this.apiBaseUrl = 'http://localhost:3000'});

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  late VideoService _videoService;
  late Future<List<Video>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videoService = VideoService(widget.apiBaseUrl);
    _videosFuture = _fetchVideos();
  }

  /// Fetch converted videos from backend
  Future<List<Video>> _fetchVideos() async {
    try {
      // Check if backend is reachable
      final isHealthy = await _videoService.healthCheck();
      if (!isHealthy) {
        throw Exception('Backend server is not responding');
      }

      // Fetch all converted videos
      final videoInfos = await _videoService.getConvertedVideos();

      // Convert VideoInfo to Video model (compatible with VideoPlayerItem)
      final videos = videoInfos.map((info) {
        return Video(
          id: info.id,
          title: info.fileName.replaceAll('.mp4', ''), // Use filename as title
          url: info.url,
          description: 'Size: ${info.fileSizeMB}MB\nConverted: ${info.created}',
          duration: const Duration(
            minutes: 1,
          ), // Default duration, update from metadata
          instructor: 'System', // Default instructor
        );
      }).toList();

      debugPrint('✅ Loaded ${videos.length} videos from backend');
      return videos;
    } catch (e) {
      debugPrint('❌ Error fetching videos: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Converted Videos'), elevation: 0),
      body: FutureBuilder<List<Video>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Fetching videos from backend...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _videosFuture = _fetchVideos();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.video_collection,
                    size: 48,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No videos available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _videosFuture = _fetchVideos();
                      });
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          final videos = snapshot.data!;

          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return VideoListTile(
                video: video,
                onTap: () {
                  // Navigate to video player or use PageView for swipe behavior
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(video: video),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _videosFuture = _fetchVideos();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

/// Individual video tile in the list
class VideoListTile extends StatelessWidget {
  final Video video;
  final VoidCallback onTap;

  const VideoListTile({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Text(
            'Instructor: ${video.instructor}',
            style: const TextStyle(fontSize: 12),
          ),
          if (video.description.isNotEmpty)
            Text(
              video.description,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      trailing: const Icon(Icons.play_circle_filled, color: Colors.blue),
      onTap: onTap,
    );
  }
}

/// Full-screen video player
class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  late bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.video.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: VideoPlayerItem(video: widget.video, isVisible: _isVisible),
          ),
          // Video info below player
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Instructor: ${widget.video.instructor}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                if (widget.video.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.video.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      setState(() => _isVisible = false);
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _isVisible = true);
    }
  }
}
