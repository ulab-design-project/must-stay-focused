import 'package:isar/isar.dart';

part 'flash_card.g.dart';

@collection
class Deck {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  String? description;

  late List<String> tags = ['default'];

  @Backlink(to: 'deck')
  final flashcards = IsarLinks<FlashCard>();

  Deck();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tags': tags,
    };
  }

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck()
      ..id = json['id'] ?? Isar.autoIncrement
      ..name = json['name']
      ..description = json['description']
      ..tags = (json['tags'] as List?)?.map((e) => e as String).toList() ?? ['default'];
  }
}

@collection
class FlashCard {
  Id id = Isar.autoIncrement;

  late String front; //question
  late String back; //answer

  final deck = IsarLink<Deck>();

  late DateTime creationDate;

  double easeFactor = 2.5;
  int repetition = 0;
  int interval = 1;
  late DateTime nextReviewDate;

  FlashCard();

  FlashCard.make({
    required this.front,
    required this.back,
    required Deck deck,
    required this.creationDate,
    this.easeFactor = 2.5,
    this.repetition = 0,
    this.interval = 1,
    DateTime? nextReviewDate,
  }) {
    this.deck.value = deck;
    this.nextReviewDate = nextReviewDate ?? DateTime.now();
  }

 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'deckId': deck.value?.id,
      'creationDate': creationDate.toIso8601String(),
    };
  }

  
  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard()
      ..id = json['id'] ?? Isar.autoIncrement
      ..front = json['front']
      ..back = json['back']
      ..creationDate = json['creationDate'] != null 
          ? DateTime.parse(json['creationDate'])
          : DateTime.now();
  }

 
  void updateSM2data(String difficulty) {
    int quality;

    switch (difficulty) {
      case 'easy':
        quality = 5;
        break;
      case 'medium':
        quality = 4;
        break;
      case 'hard':
        quality = 3;
        break;
      default:
        quality = 2; 
    }

    if (quality < 3) {
      repetition = 0;
      interval = 1;
    } else {
      repetition += 1;

      if (repetition == 1) {
        interval = 1;
      } else if (repetition == 2) {
        interval = 6;
      } else {
        interval = (interval * easeFactor).round();
      }
    }

    
    easeFactor = easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    if (easeFactor < 1.3) {
      easeFactor = 1.3;
    }
  }

  
  void calculateSM2ReviewDate() {
    nextReviewDate = DateTime.now().add(Duration(days: interval));
  }
}