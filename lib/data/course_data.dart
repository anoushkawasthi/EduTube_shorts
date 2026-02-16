import 'package:edutube_shorts/models/course.dart';
import 'package:edutube_shorts/models/topic.dart';
import 'package:edutube_shorts/models/video.dart';

class CourseData {
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
              url:
                  'https://drive.google.com/uc?id=1Bo-fuizCsyeJXgVNuJgbkxt9DImMxggn&export=download',
              duration: const Duration(minutes: 0, seconds: 0),
              description: 'Topic 1 Video 1',
            ),
            Video(
              id: 'COMM_V2',
              title: 'Video 2',
              url:
                  'https://drive.google.com/uc?id=15-3t5VtV3FAvV5P9qUO10ee5bv88ZtZI&export=download',
              duration: const Duration(minutes: 0, seconds: 0),
              description: 'Topic 1 Video 2',
            ),
            Video(
              id: 'COMM_V3',
              title: 'Video 3',
              url:
                  'https://drive.google.com/uc?id=1D6l-lkByS2U7R5Gqy0SrU_EFTekzHtZG&export=download',
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
              url:
                  'https://drive.google.com/uc?id=1OzxUql7h6CMe4HSz9qEYL6dLenYB8BgU&export=download',
              duration: const Duration(minutes: 8, seconds: 45),
              description: 'Introduction to communication fundamentals',
            ),
            Video(
              id: 'COMM_V5',
              title: 'Types of Communication',
              url:
                  'https://drive.google.com/uc?id=1q362MqfjsgyPy72AimNs7K5RoIUL9QZB&export=download',
              duration: const Duration(minutes: 12, seconds: 30),
              description: 'Explore different types and modes of communication',
            ),
            Video(
              id: 'COMM_V6',
              title: 'Modulation Part 1',
              url:
                  'https://drive.google.com/uc?id=1DjudfhL8UBaMCotMuWTzUwRU8MBk15Vx&export=download',
              duration: const Duration(minutes: 10, seconds: 15),
              description: 'Introduction to modulation techniques',
            ),
            Video(
              id: 'COMM_V7',
              title: 'Modulation Part 2',
              url:
                  'https://drive.google.com/uc?id=1nASs344N-1tDpJFjASmJnV8rDFXkvgLm&export=download',
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
              url:
                  'https://drive.google.com/uc?id=10I__w-0WJZggd7mUbdBynuraQ16hngk0&export=download',
              duration: const Duration(minutes: 10),
              description: 'LIFO data structure essentials',
            ),
            Video(
              id: 'DS_V2',
              title: 'Queue Variants',
              url:
                  'https://drive.google.com/uc?id=11IMPij-wfVcqEM61fnNT-_KS57OhEGJr&export=download',
              duration: const Duration(minutes: 11, seconds: 20),
              description: 'FIFO, circular, and deques',
            ),
            Video(
              id: 'DS_V3',
              title: 'Applications of Stacks',
              url:
                  'https://drive.google.com/uc?id=1lC7mbvfXyi4SbTAwd0AABcKJWVfbcVlw&export=download',
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
              url:
                  'https://drive.google.com/uc?id=10I__w-0WJZggd7mUbdBynuraQ16hngk0&export=download',
              duration: const Duration(minutes: 14, seconds: 15),
              description: 'Tree structure and traversal',
            ),
            Video(
              id: 'DS_V5',
              title: 'Balanced Trees (AVL)',
              url:
                  'https://drive.google.com/uc?id=1lC7mbvfXyi4SbTAwd0AABcKJWVfbcVlw&export=download',
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
              url:
                  'https://drive.google.com/uc?id=10I__w-0WJZggd7mUbdBynuraQ16hngk0&export=download',
              duration: const Duration(minutes: 16),
              description: 'Most efficient general-purpose sorting',
            ),
            Video(
              id: 'AL_V2',
              title: 'MergeSort and Stability',
              url:
                  'https://drive.google.com/uc?id=1lC7mbvfXyi4SbTAwd0AABcKJWVfbcVlw&export=download',
              duration: const Duration(minutes: 12, seconds: 50),
              description: 'Stable sorting and divide-conquer',
            ),
          ],
        ),
      ],
    ),
    // ✅ Backend Test Course - Converted Video from FFmpeg
    Course(
      id: 'TEST_001',
      title: '🎬 Backend Test Videos',
      description: 'Test videos converted from backend FFmpeg pipeline',
      topics: [
        Topic(
          id: 'TEST_T1',
          title: 'Converted Videos',
          videos: [
            Video(
              id: 'TEST_V1',
              title: 'Backend Converted Video (FFmpeg)',
              url:
                  'https://drive.google.com/uc?id=19y50cI4N0E9Pftr-tQa5d5fKj8YkrqSX&export=download',
              duration: const Duration(seconds: 1),
              description: '✅ Streamed from Google Drive | Cloud Hosted',
              instructor: 'Cloud Storage',
            ),
          ],
        ),
      ],
    ),
  ];

  /// Find a course by its ID
  static Course? getCourseById(String courseId) {
    try {
      return courses.firstWhere((course) => course.id == courseId);
    } catch (e) {
      return null;
    }
  }
}