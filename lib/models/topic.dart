import 'video.dart';

class Topic {
  final String id;
  final String title;
  final List<Video> videos;

  Topic({required this.id, required this.title, required this.videos});
}
