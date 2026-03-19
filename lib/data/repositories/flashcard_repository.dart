// File: lib/data/repositories/flashcard_repository.dart
// TODO: Implement Flashcard/Deck Data Access Layer
// Architecture: Define abstract interface and Isar implementation.
// Requirements:
// 1. Methods:
//    - `Future<void> createDeck(Deck deck)`.
//    - `Future<void> addCard(FlashCard card)`.
//    - `Future<List<FlashCard>> getCardsDueForReview()` compares `nextReviewDate` <= `DateTime.now()`.
//    - `Future<void> saveReviewSession(FlashCard updatedCard)`.
