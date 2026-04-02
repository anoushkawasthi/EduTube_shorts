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
      title: 'Motor Controller Pinout',
      description:
          'Comprehensive guide to motor controller pinout configurations and applications',
      topics: [
        Topic(
          id: 'MC_T1',
          title: 'Motor Controller Overview',
          videos: [
            Video(
              id: 'MC_V1',
              title: 'Introduction to Motor Controllers',
              url: '$_r2/temp/amanpreet1.mp4',
              duration: const Duration(minutes: 0),
              description: 'Motor controller fundamentals and pinout basics',
            ),
            Video(
              id: 'MC_V2',
              title: 'Pinout Configuration',
              url: '$_r2/temp/amanpreet2.mp4',
              duration: const Duration(minutes: 0),
              description: 'Detailed pinout and connection setup',
            ),
            Video(
              id: 'MC_V3',
              title: 'Advanced Applications',
              url: '$_r2/temp/amanpreet3.mp4',
              duration: const Duration(minutes: 0),
              description: 'Advanced motor controller applications',
            ),
          ],
        ),
      ],
    ),
    Course(
      id: 'UCS103',
      title: 'BCI',
      description:
          'Exploration of brain computer interface technology and principles',
      topics: [
        Topic(
          id: 'BCI_T1',
          title: 'BCI Fundamentals',
          videos: [
            Video(
              id: 'BCI_V1',
              title: 'Introduction to BCI',
              url: '$_r2/temp/seema1.mp4',
              duration: const Duration(minutes: 0),
              description:
                  'Basic concepts and principles of brain computer interfaces',
            ),
            Video(
              id: 'BCI_V2',
              title: 'Signal Processing',
              url: '$_r2/temp/seema2.mp4',
              duration: const Duration(minutes: 0),
              description: 'EEG signal processing and analysis techniques',
            ),
          ],
        ),
        Topic(
          id: 'BCI_T2',
          title: 'BCI Applications',
          videos: [
            Video(
              id: 'BCI_V3',
              title: 'Practical Applications',
              url: '$_r2/temp/seema3.mp4',
              duration: const Duration(minutes: 0),
              description: 'Real-world applications and use cases',
            ),
            Video(
              id: 'BCI_V4',
              title: 'Advanced Topics',
              url: '$_r2/temp/seema4.mp4',
              duration: const Duration(minutes: 0),
              description: 'Advanced BCI research and future directions',
            ),
          ],
        ),
      ],
    ),
    Course(
      id: 'UCS104',
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
