import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edutube_shorts/services/video_state_service.dart';
import 'package:edutube_shorts/models/video.dart';

class SavedVideosPage extends StatefulWidget {
  const SavedVideosPage({super.key});

  @override
  State<SavedVideosPage> createState() => _SavedVideosPageState();
}

class _SavedVideosPageState extends State<SavedVideosPage> {
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
    final videos = _service.savedVideos;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3A70),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Saved Videos'),
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
                  Icon(Icons.bookmark_outline_rounded,
                      size: 64, color: Color(0xFFD1D5DB)),
                  SizedBox(height: 16),
                  Text('No saved videos yet',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16)),
                  SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on a video\nto save it here',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
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
                    icon: const Icon(Icons.bookmark_remove_rounded,
                        color: Color(0xFFDC2626)),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _service.toggleSave(video.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Removed from saved'),
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
        color: Colors.white,
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
            color: const Color(0xFF1F3A70).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.play_circle_rounded,
              color: Color(0xFF1F3A70), size: 24),
        ),
        title: Text(
          video.title,
          style: const TextStyle(
            color: Color(0xFF0B2E4A),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          video.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
        ),
        trailing: trailing,
      ),
    );
  }
}
