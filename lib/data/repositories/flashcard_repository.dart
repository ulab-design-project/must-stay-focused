// File: lib/data/repositories/flashcard_repository.dart
// TODO: Implement Flashcard/Deck Data Access Layer
// Architecture: Define abstract interface and Isar implementation.
// Requirements:
// 1. Methods:
//    - `Future<void> createDeck(Deck deck)`.
//    - `Future<void> addCard(FlashCard card)`.
//    - `Future<List<FlashCard>> getCardsDueForReview()` compares `nextReviewDate` <= `DateTime.now()`.
//    - `Future<void> saveReviewSession(FlashCard updatedCard)`.
import 'package:isar/isar.dart';

import '../db/isar_service.dart';
import '../models/flash_card.dart';

class FlashcardRepository {
  final _isar = IsarService().db;



  Future<void> addCard(FlashCard card) async {
    await _isar.writeTxn(() async {
      await _isar.flashCards.put(card);
    });
  }

  Future<List<FlashCard>> getCardsDueForReview() async {
    final now = DateTime.now();

    return await _isar.flashCards
        .filter()
        .nextReviewDateLessThan(now)
        .findAll();
  }

  Future<void> saveReviewSession(FlashCard updatedCard) async {
    await _isar.writeTxn(() async {
      await _isar.flashCards.put(updatedCard);
    });
  }
}
