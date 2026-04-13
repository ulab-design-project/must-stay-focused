// File: lib/data/models/community_template.dart
// Server DTOS for Supabase
enum TemplateType {
  todoList,
  flashcardDeck
}

class CommunityTemplate {
  final String id;
  final TemplateType type;
  final String title;
  final String authorName;
  final int downloads;
  final double starRating;
  final String jsonPayload;
  final List<String> tags;
  final String description;

  CommunityTemplate({
    required this.id,
    required this.type,
    required this.title,
    required this.authorName,
    required this.downloads,
    required this.starRating,
    required this.jsonPayload,
    this.tags = const [],
    this.description = '',
  });

  factory CommunityTemplate.fromJson(Map<String, dynamic> json) {
    return CommunityTemplate(
      id: json['id'],
      type: TemplateType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      authorName: json['author_name'],
      downloads: json['downloads'],
      starRating: (json['star_rating'] as num).toDouble(),
      jsonPayload: json['json_payload'],
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'type': type.name,
      'title': title,
      'author_name': authorName,
      'downloads': downloads,
      'star_rating': starRating,
      'json_payload': jsonPayload,
      'tags': tags,
      'description': description,
    };
  }
}