import 'package:isar/isar.dart';
import '../db/isar_service.dart';
import '../models/flash_card.dart';
import '../models/deck.dart';

class FlashcardRepository {
 
  Future<void> createDeck(Deck deck) async {
    await idb.writeTxn(() async {
      await idb.decks.put(deck);
    });
  }

 
  Future<void> addCard(FlashCard card) async {
    await idb.writeTxn(() async {
      await idb.flashCards.put(card);
    });
  }

 
  Future<List<FlashCard>> getCardsDueForReview() async {
    final now = DateTime.now();

    return await idb.flashCards
        .filter()
        .nextReviewDateLessThan(now)
        .findAll();
  }

  
  Future<void> saveReviewSession(FlashCard updatedCard) async {
    await idb.writeTxn(() async {
      await idb.flashCards.put(updatedCard);
    });
  }

  
  Future<List<FlashCard>> getFilteredDeck({
    required String deckName,
    String? sortBy,
    bool isAscending = true,
    bool showFullDeck = false,
  }) async {
    final now = DateTime.now();

    
    List<FlashCard> cards = await idb.flashCards
        .filter()
        .deckNameEqualTo(deckName)
        .findAll();

    
    if (!showFullDeck) {
      cards = cards.where((card) {
        return card.nextReviewDate.year == now.year &&
            card.nextReviewDate.month == now.month &&
            card.nextReviewDate.day == now.day;
      }).toList();
    }

    
    if (sortBy == 'creationTime') {
      cards.sort((a, b) => isAscending
          ? a.creationDate.compareTo(b.creationDate)
          : b.creationDate.compareTo(a.creationDate));
    } else if (sortBy == 'difficulty') {
      cards.sort((a, b) => isAscending
          ? a.easeFactor.compareTo(b.easeFactor)
          : b.easeFactor.compareTo(a.easeFactor));
    }

    return cards;
  }
}