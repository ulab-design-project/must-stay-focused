// File: lib/utils/sm2_algorithm.dart
// TODO: Implement Memory Forgetting Curve Logic
// Architecture: Pure Dart functional uncoupled helper.
// Requirements:
// 1. `enum RecallQuality { forgot, hard, good, easy }` maps strictly to (0, 3, 4, 5) algorithm grades.
// 2. `class SM2Calculator`:
//    - Method: `static FlashCard calculateNextReview(FlashCard currentCard, RecallQuality quality)`
//    - Logic: Implements derived equation from Ebbinghaus memory model (FR-20).
//      - Updates `repetition`, `easeFactor`, `interval`, and `nextReviewDate` based on user's recall quality (FR-21).
