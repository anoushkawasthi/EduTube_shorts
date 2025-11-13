import 'package:edutube_shorts/models/course.dart';
import 'package:edutube_shorts/models/topic.dart';
import 'package:edutube_shorts/models/video.dart';

class CourseData {
  static final List<Course> courses = [
    Course(
      id: 'UCS101',
      title: 'Numerical Analysis',
      description: 'Master numerical methods for scientific computing',
      topics: [
        Topic(
          id: 'NA_T1',
          title: 'Root Finding Methods',
          videos: [
            Video(
              id: 'NA_V1',
              title: 'Bisection Method Introduction',
              url:
                  'https://drive.google.com/uc?id=11IMPij-wfVcqEM61fnNT-_KS57OhEGJr&export=download',
              duration: const Duration(minutes: 8, seconds: 45),
              description:
                  'Learn how the bisection method works for finding roots',
            ),
            Video(
              id: 'NA_V2',
              title: 'Newton-Raphson Method',
              url:
                  'https://drive.google.com/uc?id=1lC7mbvfXyi4SbTAwd0AABcKJWVfbcVlw&export=download',
              duration: const Duration(minutes: 12, seconds: 30),
              description: 'Understand the faster Newton-Raphson approach',
            ),
            Video(
              id: 'NA_V3',
              title: 'Secant Method Explained',
              url:
                  'https://drive.google.com/uc?id=10I__w-0WJZggd7mUbdBynuraQ16hngk0&export=download',
              duration: const Duration(minutes: 10, seconds: 15),
              description: 'Explore the secant method without derivatives',
            ),
          ],
        ),
        Topic(
          id: 'NA_T2',
          title: 'Linear Systems',
          videos: [
            Video(
              id: 'NA_V4',
              title: 'Gaussian Elimination Basics',
              url:
                  'https://drive.google.com/uc?id=11IMPij-wfVcqEM61fnNT-_KS57OhEGJr&export=download',
              duration: const Duration(minutes: 15),
              description: 'Foundation of solving linear systems',
            ),
            Video(
              id: 'NA_V5',
              title: 'LU Decomposition',
              url:
                  'https://drive.google.com/uc?id=1lC7mbvfXyi4SbTAwd0AABcKJWVfbcVlw&export=download',
              duration: const Duration(minutes: 14, seconds: 20),
              description: 'Matrix factorization for efficient solutions',
            ),
          ],
        ),
        Topic(
          id: 'NA_T3',
          title: 'Interpolation',
          videos: [
            Video(
              id: 'NA_V6',
              title: 'Lagrange Interpolation',
              url:
                  'https://drive.google.com/uc?id=10I__w-0WJZggd7mUbdBynuraQ16hngk0&export=download',
              duration: const Duration(minutes: 11, seconds: 50),
              description: 'Polynomial interpolation using Lagrange basis',
            ),
            Video(
              id: 'NA_V7',
              title: 'Spline Interpolation',
              url:
                  'https://drive.google.com/uc?id=11IMPij-wfVcqEM61fnNT-_KS57OhEGJr&export=download',
              duration: const Duration(minutes: 13, seconds: 45),
              description: 'Smooth curve fitting with splines',
            ),
            Video(
              id: 'NA_V8',
              title: 'Newton Forward Differences',
              url:
                  'https://drive.google.com/uc?id=1lC7mbvfXyi4SbTAwd0AABcKJWVfbcVlw&export=download',
              duration: const Duration(minutes: 9, seconds: 30),
              description: 'Efficient polynomial evaluation',
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
