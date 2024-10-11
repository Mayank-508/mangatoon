class WebtoonCategory {
  final String title;
  final String thumbnailUrl;
  final String description;

  WebtoonCategory({
    required this.title,
    required this.thumbnailUrl,
    required this.description,
  });

  // Convert from Map (JSON)
  factory WebtoonCategory.fromMap(Map<String, dynamic> data) {
    return WebtoonCategory(
      title: data['title'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      description: data['description'] ?? '',
    );
  }

  // Convert to Map (JSON)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
    };
  }
}
