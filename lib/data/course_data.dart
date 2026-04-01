import 'package:edutube_shorts/models/course.dart';
import 'package:edutube_shorts/models/topic.dart';
import 'package:edutube_shorts/models/video.dart';

/// R2 public base: `pub-abacf54818964401ac89e2a3d046cc4c.r2.dev`
class CourseData {
  static const String _r2 =
      'https://pub-abacf54818964401ac89e2a3d046cc4c.r2.dev';

  static final List<Course> courses = [
    Course(
      id: 'UCS101',
      title: 'Communication',
      description:
          'Comprehensive guide to communication concepts and modulation techniques',
      topics: [
        Topic(
          id: 'COMM_T1',
          title: 'Topic 1',
          videos: [
            Video(
              id: 'COMM_V1',
              title: 'Video 1',
              url: '$_r2/COMM_V1.mp4',
              duration: const Duration(minutes: 0, seconds: 0),
              description: 'Topic 1 Video 1',
            ),
            Video(
              id: 'COMM_V2',
              title: 'Video 2',
              url: '$_r2/COMM_V2.mp4',
              duration: const Duration(minutes: 0, seconds: 0),
              description: 'Topic 1 Video 2',
            ),
            Video(
              id: 'COMM_V3',
              title: 'Video 3',
              url: '$_r2/COMM_V3.mp4',
              duration: const Duration(minutes: 0, seconds: 0),
              description: 'Topic 1 Video 3',
            ),
          ],
        ),
        Topic(
          id: 'COMM_T2',
          title: 'Basics of Communication',
          videos: [
            Video(
              id: 'COMM_V4',
              title: 'What is Communication',
              url: '$_r2/COMM_V4.mp4',
              duration: const Duration(minutes: 8, seconds: 45),
              description: 'Introduction to communication fundamentals',
            ),
            Video(
              id: 'COMM_V5',
              title: 'Types of Communication',
              url: '$_r2/COMM_V5.mp4',
              duration: const Duration(minutes: 12, seconds: 30),
              description: 'Explore different types and modes of communication',
            ),
            Video(
              id: 'COMM_V6',
              title: 'Modulation Part 1',
              url: '$_r2/COMM_V6.mp4',
              duration: const Duration(minutes: 10, seconds: 15),
              description: 'Introduction to modulation techniques',
            ),
            Video(
              id: 'COMM_V7',
              title: 'Modulation Part 2',
              url: '$_r2/COMM_V7.mp4',
              duration: const Duration(minutes: 11, seconds: 20),
              description: 'Advanced modulation concepts and applications',
            ),
          ],
        ),
      ],
    ),
    Course(
      id: 'UCS102',
      title: 'Data Structures',
      description: 'Deep dive into fundamental data structures and algorithms',
      topics: [
        Topic(
          id: 'DS_T1',
          title: 'Stacks & Queues',
          videos: [
            Video(
              id: 'DS_V1',
              title: 'Stack Implementation',
              url: '$_r2/DS_V1.mp4',
              duration: const Duration(minutes: 10),
              description: 'LIFO data structure essentials',
            ),
            Video(
              id: 'DS_V2',
              title: 'Queue Variants',
              url: '$_r2/DS_V2.mp4',
              duration: const Duration(minutes: 11, seconds: 20),
              description: 'FIFO, circular, and deques',
            ),
            Video(
              id: 'DS_V3',
              title: 'Applications of Stacks',
              url: '$_r2/DS_V3.mp4',
              duration: const Duration(minutes: 12, seconds: 40),
              description: 'Practical use cases and problems',
            ),
          ],
        ),
        Topic(
          id: 'DS_T2',
          title: 'Trees & Graphs',
          videos: [
            Video(
              id: 'DS_V4',
              title: 'Binary Trees Fundamentals',
              url: '$_r2/DS_V1.mp4',
              duration: const Duration(minutes: 14, seconds: 15),
              description: 'Tree structure and traversal',
            ),
            Video(
              id: 'DS_V5',
              title: 'Balanced Trees (AVL)',
              url: '$_r2/DS_V1.mp4',
              duration: const Duration(minutes: 13),
              description: 'Maintaining O(log n) operations',
            ),
          ],
        ),
      ],
    ),
    Course(
      id: 'UCS103',
      title: 'Algorithms',
      description: 'Algorithm design, analysis, and optimization',
      topics: [
        Topic(
          id: 'AL_T1',
          title: 'Sorting Algorithms',
          videos: [
            Video(
              id: 'AL_V1',
              title: 'QuickSort Deep Dive',
              url: '$_r2/AL_V1.mp4',
              duration: const Duration(minutes: 16),
              description: 'Most efficient general-purpose sorting',
            ),
            Video(
              id: 'AL_V2',
              title: 'MergeSort and Stability',
              url: '$_r2/AL_V1.mp4',
              duration: const Duration(minutes: 12, seconds: 50),
              description: 'Stable sorting and divide-conquer',
            ),
          ],
        ),
      ],
    ),
  ];

  static Course? getCourseById(String courseId) {
    try {
      return courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }
}
