import 'package:flutter/material.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/pages/player_page.dart';
import 'package:edutube_shorts/theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// HomePage displays a list of available courses
/// Users can tap on a course card to navigate to PlayerPage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: AppShadows.card,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.xxl),
              bottomRight: Radius.circular(AppRadius.xxl),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              onPressed: () {},
            ),
            centerTitle: true,
            title: SvgPicture.asset(
              'lib/main-site-logo.svg',
              height: 32,
              width: 32,
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.md,
        ),
        itemCount: CourseData.courses.length,
        itemBuilder: (context, index) {
          final course = CourseData.courses[index];
          return CourseCard(
            courseId: course.id,
            title: course.title,
            description: course.description,
            topicCount: course.topics.length,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlayerPage(courseId: course.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// CourseCard displays a single course with its metadata
class CourseCard extends StatefulWidget {
  final String courseId;
  final String title;
  final String description;
  final int topicCount;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.courseId,
    required this.title,
    required this.description,
    required this.topicCount,
    required this.onTap,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppDurations.interaction,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: AppCurves.standard,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.soft,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Container(
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 4,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getAccentColor(widget.courseId),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.gray400,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${widget.topicCount} topics',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: theme.colorScheme.primary,
                      size: 18,
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

  Color _getAccentColor(String courseId) {
    final colors = AppColors.courseAccentBarColors;
    final hash = courseId.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
