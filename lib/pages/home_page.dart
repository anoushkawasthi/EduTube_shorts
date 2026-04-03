import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/pages/player_page.dart';
import 'package:edutube_shorts/pages/saved_videos_page.dart';
import 'package:edutube_shorts/pages/liked_videos_page.dart';
import 'package:edutube_shorts/pages/settings_page.dart';
import 'package:edutube_shorts/pages/help_feedback_page.dart';
import 'package:edutube_shorts/pages/edit_profile_page.dart';
import 'package:edutube_shorts/screens/auth_gate.dart';
import 'package:edutube_shorts/services/auth_service.dart';
import 'package:edutube_shorts/services/theme_service.dart';
import 'package:edutube_shorts/services/user_profile_service.dart';
import 'package:edutube_shorts/utils/design_tokens.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// HomePage displays a list of available courses
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final courses = CourseData.courses;

    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.cardBg,
      drawer: _buildDrawer(context),
      body: Builder(
        builder: (scaffoldContext) => CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ─── Top bar ───
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Scaffold.of(scaffoldContext).openDrawer();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Icon(Icons.menu_rounded,
                              color: colors.textPrimary, size: 22),
                        ),
                      ),
                      const Spacer(),
                      SvgPicture.asset(
                        'lib/main-site-logo.svg',
                        height: 26,
                        colorFilter: context.isDark
                            ? const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn)
                            : null,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showProfileSheet(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Icon(Icons.person_outlined,
                              color: colors.textPrimary, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Hero section (flat, no gradient) ───
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primary800,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()} 👋',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ready to study?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${courses.length} courses available',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Section header ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
                child: Row(
                  children: [
                    Text(
                      'Courses',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        '${courses.length}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Course list / empty state ───
            if (courses.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_outlined,
                          size: 48, color: AppColors.gray300),
                      SizedBox(height: 12),
                      Text('No courses yet',
                          style: TextStyle(
                              color: AppColors.gray400, fontSize: 15)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final course = courses[index];
                      final videoCount = course.topics
                          .fold<int>(0, (s, t) => s + t.videos.length);
                      return CourseCard(
                        courseId: course.id,
                        title: course.title,
                        description: course.description,
                        topicCount: course.topics.length,
                        videoCount: videoCount,
                        index: index,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlayerPage(courseId: course.id),
                            ),
                          );
                        },
                      );
                    },
                    childCount: courses.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final totalCourses = CourseData.courses.length;
    final totalTopics = CourseData.courses.fold<int>(
      0,
      (sum, c) => sum + c.topics.length,
    );
    final totalVideos = CourseData.courses.fold<int>(
      0,
      (sum, c) => sum + c.topics.fold<int>(0, (s, t) => s + t.videos.length),
    );

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.primary800,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppRadius.xxl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    'lib/main-site-logo.svg',
                    height: 36,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Thapar EduTube',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCourses courses · $totalTopics topics · $totalVideos videos',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Menu items
            _DrawerItem(
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: true,
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.bookmark_outline_rounded,
              label: 'Saved Videos',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SavedVideosPage()));
              },
            ),
            _DrawerItem(
              icon: Icons.favorite_outline_rounded,
              label: 'Liked Videos',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LikedVideosPage()));
              },
            ),

            Divider(color: AppColors.divider, indent: 20, endIndent: 20),

            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              label: 'Help & Feedback',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HelpFeedbackPage()));
              },
            ),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              onTap: () async {
                Navigator.pop(context);
                await AuthService.instance.logout();
                await UserProfileService.instance.signOut();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (route) => false,
                );
              },
            ),

            const Spacer(),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                'v1.0.0 · Made for Thapar University',
                style: TextStyle(
                  color: context.appColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    final profile = UserProfileService.instance;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Avatar
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary800,
                  child: profile.isSignedIn
                      ? Text(
                          profile.displayName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : const Icon(Icons.person_rounded,
                          color: Colors.white, size: 36),
                ),
                const SizedBox(height: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfilePage()),
                    );
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Text(
                      profile.displayName,
                      style: TextStyle(
                        color: context.appColors.heading,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stats row
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(
                          'Courses', '${CourseData.courses.length}', context),
                      Container(
                          width: 1,
                          height: 28,
                          color: context.appColors.border),
                      _buildStat(
                          'Topics',
                          '${CourseData.courses.fold<int>(0, (s, c) => s + c.topics.length)}',
                          context),
                      Container(
                          width: 1,
                          height: 28,
                          color: context.appColors.border),
                      _buildStat(
                          'Videos',
                          '${CourseData.courses.fold<int>(0, (s, c) => s + c.topics.fold<int>(0, (s2, t) => s2 + t.videos.length))}',
                          context),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Actions
                _ProfileOption(
                  icon: Icons.edit_outlined,
                  label: 'Edit Profile',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfilePage()),
                    );
                  },
                ),
                _ProfileOption(
                  icon: ThemeService.instance.isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  label: 'Dark Mode',
                  trailing: Switch.adaptive(
                    value: ThemeService.instance.isDark,
                    activeTrackColor: AppColors.primary800,
                    onChanged: (_) {
                      Navigator.pop(context);
                      ThemeService.instance.toggle();
                    },
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ThemeService.instance.toggle();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String label, String value, BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary800,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: context.appColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

/// CourseCard with press animation and new visual layout
class CourseCard extends StatefulWidget {
  final String courseId;
  final String title;
  final String description;
  final int topicCount;
  final int videoCount;
  final int index;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.courseId,
    required this.title,
    required this.description,
    required this.topicCount,
    required this.videoCount,
    required this.index,
    required this.onTap,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    // Stagger delay based on card index
    Future.delayed(Duration(milliseconds: 120 * widget.index), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) => _animationController.forward();

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() => _animationController.reverse();

  static const _accents = [
    AppColors.primary800,
    AppColors.primary500,
    AppColors.accent600,
    AppColors.primary700,
    AppColors.error,
  ];

  static const _icons = [
    Icons.cast_for_education_rounded,
    Icons.data_object_rounded,
    Icons.code_rounded,
    Icons.science_rounded,
    Icons.auto_stories_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _accents[widget.index % _accents.length];
    final icon = _icons[widget.index % _icons.length];

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: context.appColors.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: context.appColors.border),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Solid accent left bar
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.xl),
                          bottomLeft: Radius.circular(AppRadius.xl),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Course icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.10),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                              child: Icon(icon, color: accent, size: 24),
                            ),
                            const SizedBox(width: 14),
                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Course code badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.08),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Text(
                                      widget.courseId,
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      color: context.appColors.heading,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.appColors.textMuted,
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    children: [
                                      _InfoPill(
                                        icon: Icons.topic_rounded,
                                        label:
                                            '${widget.topicCount} ${widget.topicCount == 1 ? 'topic' : 'topics'}',
                                        color: AppColors.primary700,
                                      ),
                                      _InfoPill(
                                        icon: Icons.play_circle_outline_rounded,
                                        label:
                                            '${widget.videoCount} ${widget.videoCount == 1 ? 'video' : 'videos'}',
                                        color: AppColors.primary500,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Arrow
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Icon(Icons.chevron_right_rounded,
                                  color: context.appColors.textHint, size: 24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawer menu item
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isActive ? AppColors.primary800 : context.appColors.textSecondary,
        size: 22,
      ),
      title: Text(
        label,
        style: TextStyle(
          color:
              isActive ? AppColors.primary800 : context.appColors.textPrimary,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      selected: isActive,
      selectedTileColor: AppColors.primary800.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      dense: true,
      visualDensity: const VisualDensity(vertical: 0.5),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}

/// Profile bottom sheet option
class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.appColors.textSecondary, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: context.appColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded,
              color: context.appColors.textHint, size: 20),
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}

/// Small info pill showing icon + label for course card metadata
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
