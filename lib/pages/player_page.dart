import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/models/course.dart';
import 'package:edutube_shorts/models/topic.dart';
import 'package:edutube_shorts/widgets/video_player_item.dart';
import 'package:edutube_shorts/utils/video_cache_manager.dart';
import 'package:edutube_shorts/services/video_state_service.dart';

class PlayerPage extends StatefulWidget {
  final String courseId;

  const PlayerPage({super.key, required this.courseId});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with TickerProviderStateMixin {
  late Course course;
  late PageController _horizontalController;
  late Map<int, PageController> _verticalControllers;

  int _currentTopicIndex = 0;
  int _currentVideoIndex = 0;
  bool _showSwipeHint = false;
  bool _showEntryHint = false;
  Timer? _hintTimer;
  final _stateService = VideoStateService.instance;

  // Animation for swipe hint
  late AnimationController _hintAnimController;
  late Animation<double> _hintFadeAnimation;
  late Animation<Offset> _hintSlideAnimation;

  // Animation for like button
  late AnimationController _likeAnimController;

  @override
  void initState() {
    super.initState();

    course =
        CourseData.getCourseById(widget.courseId) ?? CourseData.courses.first;

    _horizontalController = PageController();

    _verticalControllers = {};
    for (int i = 0; i < course.topics.length; i++) {
      _verticalControllers[i] = PageController();
    }

    _hintAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _hintFadeAnimation = CurvedAnimation(
      parent: _hintAnimController,
      curve: Curves.easeOut,
    );
    _hintSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _hintAnimController,
      curve: Curves.easeOut,
    ));

    _likeAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _preloadInitialVideos();
    _maybeShowEntryHint();
  }

  Future<void> _maybeShowEntryHint() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('player_hint_shown') == true) return;
    await prefs.setBool('player_hint_shown', true);

    // Small delay so the first video starts loading first
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _showEntryHint = true);
    _hintAnimController.forward(from: 0);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hintAnimController.reverse().then((_) {
          if (mounted) setState(() => _showEntryHint = false);
        });
      }
    });
  }

  void _preloadInitialVideos() {
    if (course.topics.isEmpty) return;
    final cache = VideoCacheManager.instance;
    // Pre-download the next 3 videos of the first topic into cache.
    final firstTopic = course.topics.first;
    for (int i = 1; i < firstTopic.videos.length && i <= 3; i++) {
      cache.downloadFile(firstTopic.videos[i].url);
    }
    // Also pre-download the first video of the second topic.
    if (course.topics.length > 1) {
      final second = course.topics[1].videos;
      if (second.isNotEmpty) {
        cache.downloadFile(second.first.url);
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
    _hintTimer?.cancel();
    _hintAnimController.dispose();
    _likeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (course.topics.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.video_library_outlined,
                  size: 64, color: Colors.white38),
              SizedBox(height: 16),
              Text('No topics available',
                  style: TextStyle(color: Colors.white54, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: PageView.builder(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        onPageChanged: (topicIndex) {
          HapticFeedback.selectionClick();
          setState(() {
            _currentTopicIndex = topicIndex;
            _currentVideoIndex = 0;
            _hideSwipeHint();
          });
          _prefetchNextTopicFirstVideo(topicIndex);
        },
        itemCount: course.topics.length,
        itemBuilder: (context, topicIndex) {
          return _buildTopicPage(topicIndex);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1F3A70),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(course.title),
      actions: [
        if (course.topics.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentTopicIndex + 1}/${course.topics.length}',
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopicPage(int topicIndex) {
    final topic = course.topics[topicIndex];
    final verticalController = _verticalControllers[topicIndex]!;

    if (topic.videos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_outlined, size: 48, color: Colors.white38),
            SizedBox(height: 12),
            Text('No videos in this topic',
                style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: verticalController,
          scrollDirection: Axis.vertical,
          physics: const PageScrollPhysics(),
          onPageChanged: (videoIndex) {
            HapticFeedback.selectionClick();
            setState(() {
              _currentVideoIndex = videoIndex;
            });

            final isLastVideo = videoIndex == topic.videos.length - 1;
            if (isLastVideo && course.topics.length > 1) {
              _showSwipeHintAnimated();
            } else {
              _hideSwipeHint();
            }

            _prefetchNextVideo(topicIndex, videoIndex);
          },
          itemCount: topic.videos.length,
          itemBuilder: (context, videoIndex) {
            return _buildVideoPage(
                topic, topicIndex, videoIndex, verticalController);
          },
        ),

        // Swipe hint with animated fade+slide
        if (_showSwipeHint)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _hintSlideAnimation,
              child: FadeTransition(
                opacity: _hintFadeAnimation,
                child: _buildNavigationHint(),
              ),
            ),
          ),

        // First-visit entry hint
        if (_showEntryHint)
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _hintFadeAnimation,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swipe_rounded,
                          color: Colors.white70, size: 28),
                      SizedBox(height: 6),
                      Text(
                        'Swipe up for next video\nSwipe left for next topic',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPage(
    Topic topic,
    int topicIndex,
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
        isVisible = (videoIndex - currentPage).abs() < 0.5;
      }
    }

    final isLiked = _stateService.isLiked(video.id);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player
        VideoPlayerItem(
          key: ValueKey('${topic.id}_${video.id}'),
          video: video,
          isVisible: isVisible,
        ),

        // Bottom gradient for text readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom-Left: Video info + topic badge
        Positioned(
          bottom: 56,
          left: 14,
          right: 76,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Video title
              Text(
                video.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (video.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  video.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    shadows: const [
                      Shadow(blurRadius: 4, color: Colors.black54)
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              // Topic badge
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _navigateToTopicsPage();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.playlist_play_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          topic.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${videoIndex + 1}/${topic.videos.length}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right side: Action buttons
        Positioned(
          right: 12,
          bottom: 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Like button
              _buildActionButton(
                icon: isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isLiked ? Colors.redAccent : Colors.white,
                onTap: () => _toggleLike(video.id),
              ),
              const SizedBox(height: 18),
              // Info button
              _buildActionButton(
                icon: Icons.info_outline_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showTopicMetadataSheet();
                },
              ),
              const SizedBox(height: 18),
              // More button
              _buildActionButton(
                icon: Icons.more_horiz_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showMoreOptionsSheet();
                },
              ),
            ],
          ),
        ),

        // Bottom spacer
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(height: 36, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  void _toggleLike(String videoId) {
    HapticFeedback.lightImpact();
    setState(() {
      _stateService.toggleLike(videoId);
      if (_stateService.isLiked(videoId)) {
        _likeAnimController
            .forward()
            .then((_) => _likeAnimController.reverse());
      }
    });
  }

  void _showSwipeHintAnimated() {
    setState(() => _showSwipeHint = true);
    _hintAnimController.forward(from: 0);
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _hintAnimController.reverse().then((_) {
          if (mounted) setState(() => _showSwipeHint = false);
        });
      }
    });
  }

  void _hideSwipeHint() {
    _hintTimer?.cancel();
    if (_showSwipeHint) {
      _hintAnimController.reverse().then((_) {
        if (mounted) setState(() => _showSwipeHint = false);
      });
    }
  }

  void _navigateToTopicsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicsSelectionPage(
          course: course,
          currentTopic: _currentTopicIndex,
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

  void _showMoreOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentVideo =
            course.topics[_currentTopicIndex].videos[_currentVideoIndex];
        final isSaved = _stateService.isSaved(currentVideo.id);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Options',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _buildSheetOption(
                icon: isSaved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_outline_rounded,
                label: isSaved ? 'Remove from Saved' : 'Save Video',
                onTap: () {
                  _stateService.toggleSave(currentVideo.id);
                  Navigator.pop(context);
                  final saved = _stateService.isSaved(currentVideo.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            saved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Text(saved ? 'Video saved' : 'Removed from saved'),
                        ],
                      ),
                      duration: const Duration(milliseconds: 1500),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(
                          bottom: 16, left: 16, right: 16),
                      backgroundColor: saved
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF6B7280),
                    ),
                  );
                },
              ),
              _buildSheetOption(
                icon: Icons.flag_outlined,
                label: 'Report',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted')),
                  );
                },
              ),
              _buildSheetOption(
                icon: Icons.info_outline_rounded,
                label: 'About EduTube',
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('Thapar EduTube', style: TextStyle(color: Colors.white)),
        content: const Text(
          'A TikTok-style educational video platform for Thapar University students.\n\nSwipe vertically through videos, horizontally to switch topics.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 22),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      dense: true,
    );
  }

  void _showTopicMetadataSheet() {
    final topic = course.topics[_currentTopicIndex];
    final currentVideo = _currentVideoIndex + 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Video $currentVideo of ${topic.videos.length}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F3A70),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Topic ${_currentTopicIndex + 1}/${course.topics.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: topic.videos.isNotEmpty
                          ? currentVideo / topic.videos.length
                          : 0,
                      minHeight: 4,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF22C55E)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                const SizedBox(height: 12),
                // References
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'References',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                _buildReferenceLink(
                  icon: Icons.code_rounded,
                  label: 'GeeksforGeeks',
                  color: const Color(0xFF2F8D46),
                  url: 'https://www.geeksforgeeks.org',
                ),
                _buildReferenceLink(
                  icon: Icons.terminal_rounded,
                  label: 'LeetCode',
                  color: Colors.orange,
                  url: 'https://leetcode.com/',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReferenceLink({
    required IconData icon,
    required String label,
    required Color color,
    required String url,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: const Icon(Icons.open_in_new_rounded,
          color: Colors.white38, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      dense: true,
      onTap: () {
        Navigator.pop(context);
        _showLinkConfirmationDialog(url);
      },
    );
  }

  void _showLinkConfirmationDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title:
              const Text('Open Link?', style: TextStyle(color: Colors.white)),
          content: Text(
            'This will open in your browser:\n$url',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open $url')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildNavigationHint() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swipe_left_rounded, color: Colors.white70, size: 22),
            SizedBox(width: 8),
            Text(
              'Swipe for next topic',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _prefetchNextVideo(int topicIndex, int videoIndex) {
    final topic = course.topics[topicIndex];
    final cache = VideoCacheManager.instance;
    // Download the next 2 videos into cache while the user watches the current one.
    for (int offset = 1; offset <= 2; offset++) {
      final nextIdx = videoIndex + offset;
      if (nextIdx < topic.videos.length) {
        cache.downloadFile(topic.videos[nextIdx].url);
      }
    }
  }

  void _prefetchNextTopicFirstVideo(int topicIndex) {
    final cache = VideoCacheManager.instance;
    if (topicIndex + 1 < course.topics.length) {
      final nextTopic = course.topics[topicIndex + 1];
      for (int i = 0; i < nextTopic.videos.length && i < 2; i++) {
        cache.downloadFile(nextTopic.videos[i].url);
      }
    }
  }
}

/// TopicsSelectionPage with current topic indicator
class TopicsSelectionPage extends StatelessWidget {
  final Course course;
  final int currentTopic;
  final Function(int topicIndex) onTopicSelected;

  const TopicsSelectionPage({
    super.key,
    required this.course,
    required this.onTopicSelected,
    this.currentTopic = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3A70),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${course.title} — Topics'),
      ),
      body: course.topics.isEmpty
          ? const Center(
              child: Text('No topics available',
                  style: TextStyle(color: Color(0xFF9CA3AF))),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: course.topics.length,
              itemBuilder: (context, index) {
                final topic = course.topics[index];
                final isCurrent = index == currentTopic;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: isCurrent ? 3 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isCurrent
                        ? const BorderSide(color: Color(0xFF1F3A70), width: 2)
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFF1F3A70)
                            : const Color(0xFF1F3A70).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent
                                ? Colors.white
                                : const Color(0xFF1F3A70),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      topic.title,
                      style: const TextStyle(
                        color: Color(0xFF0B2E4A),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${topic.videos.length} ${topic.videos.length == 1 ? 'video' : 'videos'}',
                        style: const TextStyle(
                            color: Color(0xFF9CA3AF), fontSize: 13),
                      ),
                    ),
                    trailing: isCurrent
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Current',
                              style: TextStyle(
                                color: Color(0xFF16A34A),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Color(0xFF9CA3AF),
                            size: 16,
                          ),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onTopicSelected(index);
                    },
                  ),
                );
              },
            ),
    );
  }
}
