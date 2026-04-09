class FlashCard {
  String front;
  String back;

  
  String deckId;

  DateTime creationDate;

  double easeFactor;
  int repetition;
  int interval;
  DateTime nextReviewDate;

  FlashCard({
    required this.front,
    required this.back,
    required this.deckId,
    required this.creationDate,
    this.easeFactor = 2.5,
    this.repetition = 0,
    this.interval = 1,
    DateTime? nextReviewDate,
  }) : nextReviewDate = nextReviewDate ?? DateTime.now();

 
  Map<String, dynamic> toJson() {
    return {
      'front': front,
      'back': back,
      'deckId': deckId,
      'creationDate': creationDate.toIso8601String(),
      'easeFactor': easeFactor,
      'repetition': repetition,
      'interval': interval,
      'nextReviewDate': nextReviewDate.toIso8601String(),
    };
  }

  
  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      front: json['front'],
      back: json['back'],
      deckId: json['deckId'],
      creationDate: DateTime.parse(json['creationDate']),
      easeFactor: json['easeFactor'] ?? 2.5,
      repetition: json['repetition'] ?? 0,
      interval: json['interval'] ?? 1,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'])
          : DateTime.now(),
    );
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