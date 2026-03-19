// File: lib/widgets/challenge/flashcard_challenge.dart
// TODO: Implement Flashcard Quiz Intercept Challenge
// Requirements:
// 1. `class FlashcardChallengeWidget extends StatelessWidget`:
//    - Pulls a high-priority 'due-for-review' flashcard.
//    - User must recall, flip, and self-rate.
//    - Only triggers `onSuccess` if user rates "Easy" or "Hard" (prevents unlocking by default if 'Forgot' is hit) (FR-25).
