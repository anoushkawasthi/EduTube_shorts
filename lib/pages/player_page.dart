import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/models/course.dart';
import 'package:edutube_shorts/models/topic.dart';
import 'package:edutube_shorts/widgets/video_player_item.dart';

/// PlayerPage displays a TikTok-style nested swipe UI for educational videos
///
/// Structure:
/// - Outer PageView (Horizontal): Swipe left/right between Topics
/// - Inner PageView (Vertical): Swipe up/down between Videos within a Topic
///
/// This design prioritizes vertical swipes (video progression) over horizontal swipes (topic navigation)
class PlayerPage extends StatefulWidget {
  final String courseId;

  const PlayerPage({super.key, required this.courseId});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late Course course;
  late PageController _horizontalController;
  late Map<int, PageController> _verticalControllers;

  @override
  void initState() {
    super.initState();

    // Load course data
    course =
        CourseData.getCourseById(widget.courseId) ?? CourseData.courses.first;

    // Initialize horizontal PageController for topics
    _horizontalController = PageController();

    // Initialize a PageController for each topic's vertical swipes
    _verticalControllers = {};
    for (int i = 0; i < course.topics.length; i++) {
      _verticalControllers[i] = PageController();
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    for (var controller in _verticalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Keep video player dark
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3A70), // Deep blue
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          course.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        onPageChanged: (topicIndex) {
          setState(() {});
          // M+1 Prefetching: Preload first video of next topic (horizontal)
          _prefetchNextTopicFirstVideo(topicIndex);
        },
        itemCount: course.topics.length,
        itemBuilder: (context, topicIndex) {
          return _buildTopicPage(topicIndex);
        },
      ),
    );
  }

  /// Builds a single topic page with vertical video swipe
  Widget _buildTopicPage(int topicIndex) {
    final topic = course.topics[topicIndex];
    final verticalController = _verticalControllers[topicIndex]!;

    return GestureDetector(
      // Absorb gestures at the topic level to prioritize vertical swipes
      onVerticalDragDown: (_) => {},
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Vertical PageView for videos within this topic
          PageView.builder(
            controller: verticalController,
            scrollDirection: Axis.vertical,
            physics: const PageScrollPhysics(),
            onPageChanged: (videoIndex) {
              // Force rebuild to update isVisible flag
              setState(() {});
              // N+1 Prefetching: Prefetch next video in current topic
              _prefetchNextVideo(topicIndex, videoIndex);
            },
            itemCount: topic.videos.length,
            itemBuilder: (context, videoIndex) {
              return _buildVideoPage(topic, videoIndex, verticalController);
            },
          ),
          // Topic metadata overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: _buildTopicMetadata(topic, topicIndex, verticalController),
          ),
          // Horizontal swipe hint (shown when at topic boundaries)
          if (topicIndex == 0 || topicIndex == course.topics.length - 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildNavigationHint(),
            ),
        ],
      ),
    );
  }

  /// Builds the video display page
  Widget _buildVideoPage(
    Topic topic,
    int videoIndex,
    PageController verticalController,
  ) {
    final video = topic.videos[videoIndex];

    // Determine if this video is currently visible
    // Use both current page and nextPageIndex to handle transition states
    bool isVisible = false;
    if (verticalController.hasClients) {
      final currentPage = verticalController.page ?? 0;
      final roundedPage = currentPage.round();
      // Video is visible if it matches the current or next page during transition
      isVisible =
          (videoIndex == roundedPage) ||
          (videoIndex == currentPage.ceil() && currentPage != roundedPage);
    }

    return VideoPlayerItem(
      key: ValueKey('${topic.id}_${video.id}'),
      video: video,
      isVisible: isVisible,
    );
  }

  /// Builds the topic metadata overlay showing title and progress
  Widget _buildTopicMetadata(
    Topic topic,
    int topicIndex,
    PageController verticalController,
  ) {
    return AnimatedBuilder(
      animation: verticalController,
      builder: (context, child) {
        final currentVideoIndex =
            (verticalController.hasClients
                    ? verticalController.page?.round() ?? 0
                    : 0)
                .clamp(0, topic.videos.length - 1);
        final totalVideos = topic.videos.length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Topic ${topicIndex + 1}: ${topic.title}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentVideoIndex + 1}/$totalVideos videos',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Topic progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${topicIndex + 1}/${course.topics.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds navigation hint for horizontal swipes between topics
  Widget _buildNavigationHint() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.swipe_left, color: Colors.white24, size: 32),
          const SizedBox(height: 8),
          Text(
            'Swipe left to explore more topics',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// N+1 Prefetching: Prefetch next video in current topic (vertical swipe)
  void _prefetchNextVideo(int topicIndex, int videoIndex) {
    final topic = course.topics[topicIndex];

    // Bounds check: only prefetch if there's a next video
    if (videoIndex + 1 < topic.videos.length) {
      final nextVideo = topic.videos[videoIndex + 1];
      debugPrint('🎬 N+1 Prefetch: ${topic.title} → ${nextVideo.title}');
      DefaultCacheManager().downloadFile(nextVideo.url);
    }
  }

  /// M+1 Prefetching: Prefetch first video of next topic (horizontal swipe)
  void _prefetchNextTopicFirstVideo(int topicIndex) {
    // Bounds check: only prefetch if there's a next topic
    if (topicIndex + 1 < course.topics.length) {
      final nextTopic = course.topics[topicIndex + 1];
      if (nextTopic.videos.isNotEmpty) {
        final nextVideoUrl = nextTopic.videos.first.url;
        debugPrint(
          '🎬 M+1 Prefetch: ${nextTopic.title} → ${nextTopic.videos.first.title}',
        );
        DefaultCacheManager().downloadFile(nextVideoUrl);
      }
    }
  }
}
