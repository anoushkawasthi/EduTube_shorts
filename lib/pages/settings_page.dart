import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edutube_shorts/utils/video_cache_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoplay = true;
  bool _wifiOnly = false;
  bool _notifications = true;
  double _playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F3A70),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ─── Playback ───
          _SectionHeader(label: 'Playback'),
          _SettingsTile(
            icon: Icons.play_circle_outline_rounded,
            title: 'Autoplay Videos',
            subtitle: 'Automatically play next video',
            trailing: Switch.adaptive(
              value: _autoplay,
              activeColor: const Color(0xFF1F3A70),
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _autoplay = v);
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.speed_rounded,
            title: 'Playback Speed',
            subtitle: '${_playbackSpeed}x',
            trailing: DropdownButton<double>(
              value: _playbackSpeed,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 0.5, child: Text('0.5x')),
                DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                DropdownMenuItem(value: 2.0, child: Text('2.0x')),
              ],
              onChanged: (v) {
                if (v != null) {
                  HapticFeedback.selectionClick();
                  setState(() => _playbackSpeed = v);
                }
              },
            ),
          ),

          const SizedBox(height: 8),

          // ─── Network ───
          _SectionHeader(label: 'Network'),
          _SettingsTile(
            icon: Icons.wifi_rounded,
            title: 'Wi-Fi Only Streaming',
            subtitle: 'Only stream videos on Wi-Fi',
            trailing: Switch.adaptive(
              value: _wifiOnly,
              activeColor: const Color(0xFF1F3A70),
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _wifiOnly = v);
              },
            ),
          ),

          const SizedBox(height: 8),

          // ─── Notifications ───
          _SectionHeader(label: 'Notifications'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Get notified about new content',
            trailing: Switch.adaptive(
              value: _notifications,
              activeColor: const Color(0xFF1F3A70),
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _notifications = v);
              },
            ),
          ),

          const SizedBox(height: 8),

          // ─── Storage ───
          _SectionHeader(label: 'Storage'),
          _SettingsTile(
            icon: Icons.cached_rounded,
            title: 'Clear Video Cache',
            subtitle: 'Free up storage space',
            onTap: () async {
              HapticFeedback.mediumImpact();
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Clear Cache?'),
                  content: const Text('This will remove all cached videos. They will be re-downloaded when you watch them again.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear', style: TextStyle(color: Color(0xFFDC2626))),
                    ),
                  ],
                ),
              );
              if (confirmed == true && mounted) {
                await VideoCacheManager.instance.emptyCache();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared successfully')),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 8),

          // ─── About ───
          _SectionHeader(label: 'About'),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: '1.0.0',
          ),
          _SettingsTile(
            icon: Icons.school_rounded,
            title: 'Built for',
            subtitle: 'Thapar University',
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF1F3A70),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1F3A70).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1F3A70), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0B2E4A),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
