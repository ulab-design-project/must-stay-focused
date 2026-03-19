// File: lib/data/models/community_template.dart
// TODO: Implement Server DTOS for Supabase
// Architecture: Pure Dart serializable models mapped from PostgreSQL jsonb.
// Requirements:
// 1. `enum TemplateType { todoList, flashcardDeck }`.
// 2. `class CommunityTemplate`:
//    - Fields: `String id`, `TemplateType type`, `String title`, `String authorName`, `int downloads`, `double starRating`, `String jsonPayload` (holds the actual tasks/cards to import) (FR-35, FR-36, FR-38).
// 3. Methods: `fromJson`, `toJson`.
