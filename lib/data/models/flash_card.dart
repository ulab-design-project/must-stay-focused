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
import 'package:isar/isar.dart';

part 'flash_card.g.dart';

@collection
class FlashCard
{
  FlashCard();

  Id id = Isar.autoIncrement;

  late String frontText;
  late String backText;

  late int deckId;

  late DateTime nextReviewDate;

  double interval = 1.0;
  int repetition = 0;
  double easeFactor = 2.5;

  factory FlashCard.fromJson(Map<String, dynamic> json)
  {
    return FlashCard()
      ..id = json['id'] ?? Isar.autoIncrement
      ..frontText = json['front_text']
      ..backText = json['back_text']
      ..deckId = json['deck_id']
      ..nextReviewDate = DateTime.parse(json['next_review_date'])
      ..interval = (json['interval'] as num).toDouble()
      ..repetition = json['repetition']
      ..easeFactor = (json['ease_factor'] as num).toDouble();
  }

  Map<String, dynamic> toJson()
  {
    return {
      'id': id,
      'front_text': frontText,
      'back_text': backText,
      'deck_id': deckId,
      'next_review_date': nextReviewDate.toIso8601String(),
      'interval': interval,
      'repetition': repetition,
      'ease_factor': easeFactor,
    };
  }
}
