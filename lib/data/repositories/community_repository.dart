// File: lib/data/repositories/community_repository.dart
// TODO: Implement Remote Templates Access
// Architecture: Uses `SupabaseClient` instance. Abstract interface for clean testing.
// Requirements:
// 1. Methods:
//    - `Future<List<CommunityTemplate>> fetchTemplates(TemplateType type, int page, int limit)`
//    - `Future<void> uploadTemplate(CommunityTemplate data)` (Uploads require minimal anonymous Auth).
//    - `Future<void> reportTemplate(String id)` (FR-39).
