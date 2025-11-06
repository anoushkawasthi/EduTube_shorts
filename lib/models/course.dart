import 'topic.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final List<Topic> topics;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.topics,
  });
}
