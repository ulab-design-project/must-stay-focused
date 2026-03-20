// File: lib/data/models/community_template.dart
// TODO: Implement Server DTOS for Supabase
// Architecture: Pure Dart serializable models mapped from PostgreSQL jsonb.
// Requirements:
// 1. `enum TemplateType { todoList, flashcardDeck }`.
// 2. `class CommunityTemplate`:
//    - Fields: `String id`, `TemplateType type`, `String title`, `String authorName`, `int downloads`, `double starRating`, `String jsonPayload` (holds the actual tasks/cards to import) (FR-35, FR-36, FR-38).
// 3. Methods: `fromJson`, `toJson`.
enum TemplateType
{
  todoList,
  flashcardDeck
}

class CommunityTemplate
{
  final String id;
  final TemplateType type;
  final String title;
  final String authorName;
  final int downloads;
  final double starRating;
  final String jsonPayload;

  CommunityTemplate({
    required this.id,
    required this.type,
    required this.title,
    required this.authorName,
    required this.downloads,
    required this.starRating,
    required this.jsonPayload,
  });

  factory CommunityTemplate.fromJson(Map<String, dynamic> json)
  {
    return CommunityTemplate(
      id: json['id'],
      type: TemplateType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      title: json['title'],
      authorName: json['author_name'],
      downloads: json['downloads'],
      starRating: (json['star_rating'] as num).toDouble(),
      jsonPayload: json['json_payload'],
    );
  }

  Map<String, dynamic> toJson()
  {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'author_name': authorName,
      'downloads': downloads,
      'star_rating': starRating,
      'json_payload': jsonPayload,
    };
  }
}
