import 'package:isar/isar.dart';
import '../db/isar_service.dart';
import '../models/flash_card.dart';

final FlashcardRepository flashcardRepo = FlashcardRepository();

class FlashcardRepository {
 
  Future<int> upsertDeck(Deck deck) async {
    return await idb.writeTxn(() async {
      return await idb.decks.put(deck);
    });
  }

  Future<void> deleteDeck(Deck deck, {bool mergeToDefault = false}) async {
    if (deck.name == 'Default') {
      throw Exception('Cannot delete default deck');
    }
    
    if (mergeToDefault) {
      await idb.writeTxn(() async {
        await deck.flashcards.load();
        final defaultDeck = await idb.decks.filter().nameEqualTo('Default').findFirst();
        if (defaultDeck != null) {
          for (final card in deck.flashcards) {
            card.deck.value = defaultDeck;
            await idb.flashCards.put(card);
            await card.deck.save();
          }
        }
        await idb.decks.delete(deck.id);
      });
    } else {
      await idb.writeTxn(() async {
        await idb.decks.delete(deck.id);
      });
    }
  }

  Future<Deck?> getDeckByName(String deckName) async {
    return await idb.decks.filter().nameEqualTo(deckName).findFirst();
  }

  Future<List<Deck>> getAllDecks() async {
    return await idb.decks.where().findAll();
  }

 
  Future<int> upsertFlashCard(FlashCard card) async {
    return await idb.writeTxn(() async {
      final id = await idb.flashCards.put(card);
      await card.deck.save();
      return id;
    });
  }

  Future<void> deleteFlashCard(int id) async {
    await idb.writeTxn(() async {
      await idb.flashCards.delete(id);
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
    await upsertFlashCard(updatedCard);
  }

  
  Future<List<FlashCard>> getFilteredDeck({
    required String deckName,
    String? sortBy,
    bool isAscending = true,
    bool showFullDeck = false,
  }) async {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    List<FlashCard> cards;

    if (!showFullDeck) {
      cards = await idb.flashCards
          .filter()
          .deck((q) => q.nameEqualTo(deckName))
          .nextReviewDateLessThan(todayEnd)
          .findAll();
    } else {
      cards = await idb.flashCards
          .filter()
          .deck((q) => q.nameEqualTo(deckName))
          .findAll();
    }

    if (sortBy == 'creationTime') {
      cards.sort((a, b) => isAscending
          ? a.creationDate.compareTo(b.creationDate)
          : b.creationDate.compareTo(a.creationDate));
    } else if (sortBy == 'sm2' && showFullDeck) {
      cards.sort((a, b) {
        // Step 1: compare dates (normalized to midnight)
        final DateTime aDate = DateTime(a.nextReviewDate.year, a.nextReviewDate.month, a.nextReviewDate.day);
        final DateTime bDate = DateTime(b.nextReviewDate.year, b.nextReviewDate.month, b.nextReviewDate.day);
        
        final dateCompare = aDate.compareTo(bDate);
        if (dateCompare != 0) {
          return isAscending ? dateCompare : -dateCompare; // or keep date ascending always? Let's use isAscending
        }
        
        // Step 2: compare by ease factor within the same day
        return isAscending
            ? a.easeFactor.compareTo(b.easeFactor)
            : b.easeFactor.compareTo(a.easeFactor);
      });
    } else if (sortBy == 'difficulty' || sortBy == 'sm2') {
      cards.sort((a, b) => isAscending
          ? a.easeFactor.compareTo(b.easeFactor)
          : b.easeFactor.compareTo(a.easeFactor));
    }

    return cards;
  }
}