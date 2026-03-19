// File: lib/data/models/deck.dart
// TODO: Implement Deck Entity
// Architecture: Isar annotated Model class to group FlashCards.
// Requirements:
// 1. `@collection class Deck`:
//    - `Id id = Isar.autoIncrement;`
//    - `String name;`
//    - `String subjectColorHex;` (e.g. '#FF0000' for quick visual ID) (FR-19).
//    - `@Backlink` or relation to `List<FlashCard>`.
