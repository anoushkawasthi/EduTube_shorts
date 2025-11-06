class Video {
  final String id;
  final String title;
  final String url;
  final Duration duration;
  final String description;
  final String? instructor; 

  Video({
    required this.id,
    required this.title,
    required this.url,
    required this.duration,
    required this.description,
    this.instructor,
  });
}
