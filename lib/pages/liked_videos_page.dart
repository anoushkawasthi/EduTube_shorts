import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edutube_shorts/services/video_state_service.dart';
import 'package:edutube_shorts/models/video.dart';
import 'package:edutube_shorts/utils/design_tokens.dart';

class LikedVideosPage extends StatefulWidget {
  const LikedVideosPage({super.key});

  @override
  State<LikedVideosPage> createState() => _LikedVideosPageState();
}

class _LikedVideosPageState extends State<LikedVideosPage> {
  final _service = VideoStateService.instance;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final videos = _service.likedVideos;

    return Scaffold(
      backgroundColor: context.appColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary800,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Liked Videos'),
        actions: [
          if (videos.isNotEmpty)
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
                    '${videos.length}',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: videos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline_rounded,
                      size: 64, color: AppColors.gray300),
                  SizedBox(height: 16),
                  Text('No liked videos yet',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on a video\nto like it',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.gray300, fontSize: 13),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return _VideoTile(
                  video: video,
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite_rounded,
                        color: AppColors.accent600),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _service.toggleLike(video.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Removed from liked'),
                            duration: Duration(seconds: 1)),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final Video video;
  final Widget? trailing;

  const _VideoTile({required this.video, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.appColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent600.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(Icons.favorite_rounded,
              color: AppColors.accent600, size: 24),
        ),
        title: Text(
          video.title,
          style: TextStyle(
            color: context.appColors.heading,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          video.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: context.appColors.textMuted, fontSize: 12),
        ),
        trailing: trailing,
      ),
    );
  }
}
