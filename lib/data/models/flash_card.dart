// File: lib/data/models/flash_card.dart
// TODO: Implement FlashCard Data Entity
// Architecture: Isar annotated Model class holding Spaced Repetition state.
// Requirements:
// 1. `@collection class FlashCard`:
//    - `Id id = Isar.autoIncrement;`
//    - `String frontText;` (FR-18)
//    - `String backText;`
//    - `int deckId;` (Foreign key conceptually referencing a Deck)
//    - `DateTime nextReviewDate;` (FR-20)
//    - `double interval = 1.0;` (SM-2 data)
//    - `int repetition = 0;` (SM-2 data)
//    - `double easeFactor = 2.5;` (SM-2 data)
// 2. Methods: toJson/fromJson.
