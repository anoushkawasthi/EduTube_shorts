import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:edutube_shorts/utils/video_connection_warmup.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/models/course.dart';
import 'package:edutube_shorts/models/topic.dart';
import 'package:edutube_shorts/widgets/video_player_item.dart';
import 'package:edutube_shorts/theme/theme.dart';

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
  bool _showSwipeHint = false; // Show swipe hint when at last video
  Timer? _hintTimer; // Timer for hiding the hint
  final Set<String> _likedVideoIds = {}; // Track which videos are liked

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _warmUpInitialVideos();
    });
  }

  /// Prime the next clips so the first swipes feel instant (POC).
  void _warmUpInitialVideos() {
    if (course.topics.isEmpty) {
      return;
    }
    final first = course.topics.first.videos;
    for (var i = 1; i < first.length && i < 4; i++) {
      VideoConnectionWarmup.warmInBackground(first[i].url);
    }
    if (course.topics.length > 1) {
      final second = course.topics[1].videos;
      if (second.isNotEmpty) {
        VideoConnectionWarmup.warmInBackground(second.first.url);
      }
    }
  }

  bool _isTopicHorizontallyActive(int topicIndex) {
    if (!_horizontalController.hasClients) {
      return topicIndex == 0;
    }
    final page = _horizontalController.page ?? 0;
    return topicIndex == page.round();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    for (var controller in _verticalControllers.values) {
      controller.dispose();
    }
    _hintTimer?.cancel(); // Cancel timer when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Keep video player dark
      appBar: AppBar(
        backgroundColor: AppColors.primary800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          course.title,
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: PageView.builder(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        onPageChanged: (topicIndex) {
          setState(() {
            _hintTimer?.cancel(); // Cancel timer when changing topics
            _showSwipeHint = false; // Hide hint when changing topics
          });
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
              // Check if this is the last video in the topic
              final isLastVideo = videoIndex == topic.videos.length - 1;

              if (isLastVideo) {
                // Show hint when at last video
                setState(() {
                  _showSwipeHint = true;
                });
                // Cancel previous timer if it exists
                _hintTimer?.cancel();
                // Start 4-second timer to hide the hint
                _hintTimer = Timer(const Duration(seconds: 4), () {
                  if (mounted) {
                    setState(() {
                      _showSwipeHint = false;
                    });
                  }
                });
              } else {
                // Hide hint when not at last video
                _hintTimer?.cancel();
                setState(() {
                  _showSwipeHint = false;
                });
              }

              // N+1 Prefetching: Prefetch next video in current topic
              _prefetchNextVideo(topicIndex, videoIndex);
            },
            itemCount: topic.videos.length,
            itemBuilder: (context, videoIndex) {
              return _buildVideoPage(
                topicIndex,
                topic,
                videoIndex,
                verticalController,
              );
            },
          ),

          // Horizontal swipe hint (shown only when at last video and _showSwipeHint is true)
          if (_showSwipeHint)
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

  /// Builds the video display page with complete UI overlay
  Widget _buildVideoPage(
    int topicIndex,
    Topic topic,
    int videoIndex,
    PageController verticalController,
  ) {
    final video = topic.videos[videoIndex];

    final topicActive = _isTopicHorizontallyActive(topicIndex);
    bool isVisible = false;
    if (topicActive) {
      if (!verticalController.hasClients) {
        isVisible = videoIndex == 0;
      } else {
        final currentPage = verticalController.page ?? 0;
        final roundedPage = currentPage.round();
        isVisible =
            (videoIndex == roundedPage) ||
            (videoIndex == currentPage.ceil() && currentPage != roundedPage);
      }
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // ============ VIDEO PLAYER LAYER ============
        VideoPlayerItem(
          key: ValueKey('${topic.id}_${video.id}'),
          video: video,
          isVisible: isVisible,
        ),

        // ============ UI OVERLAY LAYER ============
        // Bottom-Left: Tappable Topic (Topic Selector) - Always visible
        Positioned(
          bottom: 60,
          left: 12,
          child: GestureDetector(
            onTap: () => _navigateToTopicsPage(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${topic.videos.length} videos',
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Side-Right: Action Buttons (Like, Info, More) - Vertically Aligned with Equal Spacing
        Positioned(
          right: 12,
          bottom: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Like Button - Fills with white when liked
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_likedVideoIds.contains(video.id)) {
                      _likedVideoIds.remove(video.id);
                      debugPrint('👎 Unliked video: ${video.id}');
                    } else {
                      _likedVideoIds.add(video.id);
                      debugPrint('❤️ Liked video: ${video.id}');
                    }
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _likedVideoIds.contains(video.id)
                        ? Icons.thumb_up_alt
                        : Icons.thumb_up_alt_outlined,
                    color: _likedVideoIds.contains(video.id)
                        ? Colors.white
                        : Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Info Button
              GestureDetector(
                onTap: _showTopicMetadataSheet,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // More Options Button
              GestureDetector(
                onTap: _showMoreOptionsSheet,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Black space at the bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(height: 40, color: Colors.black),
        ),

        // More Options Button (Below Share) - REMOVED (now in Column above)
      ],
    );
  }

  /// Navigate to a full-screen topics selection page
  void _navigateToTopicsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicsSelectionPage(
          course: course,
          onTopicSelected: (topicIndex) {
            Navigator.pop(context);
            _horizontalController.animateToPage(
              topicIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }

  /// Show bottom sheet for more options
  void _showMoreOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.gray900,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Options',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_outline, color: Colors.white),
              title: const Text(
                'Add to Playlist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to playlist')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.white),
              title: const Text(
                'Report',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Show bottom sheet with topic metadata and info
  void _showTopicMetadataSheet() {
    // Find current topic index
    int currentTopicIndex = _horizontalController.hasClients
        ? _horizontalController.page?.round() ?? 0
        : 0;
    final topic = course.topics[currentTopicIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.gray900,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic Information Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Topic ${currentTopicIndex + 1}: ${topic.title}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${topic.videos.length}/${topic.videos.length} videos',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary800,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Text(
                        '${currentTopicIndex + 1}/${course.topics.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey, height: 1),
              // References Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'References',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppColors.primary600),
                title: const Text(
                  'GeeksforGeeks',
                  style: TextStyle(color: Colors.white),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showLinkConfirmationDialog('https://www.geeksforgeeks.org');
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppColors.warning),
                title: const Text(
                  'LeetCode',
                  style: TextStyle(color: Colors.white),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  Navigator.pop(context);
                  _showLinkConfirmationDialog('https://leetcode.com/');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Show confirmation dialog before launching URL
  void _showLinkConfirmationDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.gray800,
          title: const Text(
            'Open Link?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Open this link in your browser?\n\n$url',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Open'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _launchURL(url);
              },
            ),
          ],
        );
      },
    );
  }

  /// Launch URL in browser
  Future<void> _launchURL(String url) async {
    debugPrint('🔗 Attempting to launch URL: $url');
    final uri = Uri.parse(url);
    try {
      final canLaunch = await canLaunchUrl(uri);
      debugPrint('🔗 Can launch URL: $canLaunch');

      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('🔗 Successfully launched URL: $url');
      } else {
        debugPrint('❌ Cannot launch URL: $url');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
        }
      }
    } catch (e) {
      debugPrint('❌ Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error launching URL: $e')));
      }
    }
  }

  /// Handle like video action

  /// Builds the topic metadata overlay showing title and progress
  /// Builds navigation hint for horizontal swipes between topics
  Widget _buildNavigationHint() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.swipe_left, color: AppColors.primary600, size: 32),
          const SizedBox(height: 8),
          Text(
            'Swipe left to explore more topics',
            style: TextStyle(
              color: AppColors.primary600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// N+1: warm next video in current topic (vertical swipe)
  void _prefetchNextVideo(int topicIndex, int videoIndex) {
    final topic = course.topics[topicIndex];

    if (videoIndex + 1 < topic.videos.length) {
      final nextVideo = topic.videos[videoIndex + 1];
      debugPrint('🎬 N+1 warm: ${topic.title} → ${nextVideo.title}');
      VideoConnectionWarmup.warmInBackground(nextVideo.url);
    }
    if (videoIndex + 2 < topic.videos.length) {
      VideoConnectionWarmup.warmInBackground(topic.videos[videoIndex + 2].url);
    }
  }

  /// M+1: warm first video of next topic (horizontal swipe)
  void _prefetchNextTopicFirstVideo(int topicIndex) {
    if (topicIndex + 1 < course.topics.length) {
      final nextTopic = course.topics[topicIndex + 1];
      if (nextTopic.videos.isNotEmpty) {
        debugPrint(
          '🎬 M+1 warm: ${nextTopic.title} → ${nextTopic.videos.first.title}',
        );
        VideoConnectionWarmup.warmInBackground(nextTopic.videos.first.url);
      }
    }
  }
}

/// TopicsSelectionPage - A dedicated full-screen page for selecting topics
class TopicsSelectionPage extends StatelessWidget {
  final Course course;
  final Function(int topicIndex) onTopicSelected;

  const TopicsSelectionPage({
    super.key,
    required this.course,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Topic',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: course.topics.length,
        itemBuilder: (context, index) {
          final topic = course.topics[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary800,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                topic.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${topic.videos.length} videos',
                style: TextStyle(color: AppColors.gray500, fontSize: 14),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
              onTap: () {
                onTopicSelected(index);
              },
            ),
          );
        },
      ),
    );
  }
}
