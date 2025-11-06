import 'package:flutter/material.dart';
import 'package:edutube_shorts/data/course_data.dart';
import 'package:edutube_shorts/pages/player_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// HomePage displays a list of available courses
/// Users can tap on a course card to navigate to PlayerPage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light gray-blue background
      appBar: AppBar(
        backgroundColor: const Color(
          0xFF1F3A70,
        ), // Deep blue (from Thapar brand)
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('lib/main-site-logo.svg', height: 32, width: 32),
            const SizedBox(width: 12),
            const Text(
              'Thapar EduTube',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
class CourseCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white, // White card background
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        elevation: 2, // Subtle shadow
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getColorByIndex(courseId),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF1F3A70), // Deep blue
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(
                            color: Color(0xFF7A8BA8), // Muted blue-gray
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: const Color(0xFFC4CEE0), // Light blue-gray
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8E6C9), // Pastel green (from website)
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$topicCount topics',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32), // Dark green
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorByIndex(String courseId) {
    final hash = courseId.hashCode;
    // Pastel colors matching Thapar website
    final colors = [
      const Color(0xFFC8E6C9), // Pastel Green
      const Color(0xFFB3E5FC), // Pastel Blue
      const Color(0xFFFFCCBC), // Pastel Orange
      const Color(0xFFF8BBD0), // Pastel Pink
    ];
    return colors[hash.abs() % colors.length];
  }
}
