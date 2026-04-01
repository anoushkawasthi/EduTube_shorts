import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/pages/player_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// HomePage displays a list of available courses
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = CourseData.courses;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded,
                  color: Color(0xFF0B2E4A), size: 26),
              onPressed: () {
                HapticFeedback.lightImpact();
              },
            ),
            centerTitle: true,
            title: SvgPicture.asset(
              'lib/main-site-logo.svg',
              height: 32,
              width: 32,
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.person_outline_rounded,
                  color: Color(0xFF0B2E4A),
                  size: 24,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
              ),
            ],
          ),
        ),
      ),
      body: courses.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined,
                      size: 64, color: Color(0xFF9CA3AF)),
                  SizedBox(height: 16),
                  Text(
                    'No courses available',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseCard(
                  courseId: course.id,
                  title: course.title,
                  description: course.description,
                  topicCount: course.topics.length,
                  onTap: () {
                    HapticFeedback.mediumImpact();
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

/// CourseCard with press animation and visual polish
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
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    final accentColor = _getAccentColor(widget.courseId);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Left accent bar
                  Container(
                    width: 4,
                    height: 72,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: Color(0xFF0B2E4A),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF22C55E).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.topicCount} ${widget.topicCount == 1 ? 'topic' : 'topics'}',
                            style: const TextStyle(
                              color: Color(0xFF16A34A),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: accentColor,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAccentColor(String courseId) {
    // Colors from the same formal navy/blue family
    final colors = [
      const Color(0xFF0B2E4A), // Navy (primary)
      const Color(0xFF1F3A70), // Deep blue
      const Color(0xFF2E5090), // Medium blue
      const Color(0xFF3A5FA1), // Sky blue
      const Color(0xFF1A4D7B), // Ocean blue
    ];
    final hash = courseId.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
