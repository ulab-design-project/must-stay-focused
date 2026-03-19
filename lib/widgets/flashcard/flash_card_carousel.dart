// File: lib/widgets/flashcard/flash_card_carousel.dart
// TODO: Implement Review Carousel
// Requirements:
// 1. `class FlashCardCarousel extends StatefulWidget`:
//    - Properties: `final List<FlashCard> cardsDueForReview`, `final Function(FlashCard, RecallRating) onRated`.
//    - Uses `PageView` horizontally (FR-23).
//    - Interaction: 
//      - Upon flipping a `FlashCardWidget`, reveal 3 response buttons below it: "Easy, Hard, Forgot" (FR-21).
//      - Trigger `onRated` callback to adjust SM-2 scheduling, then animate clearly to the next card.
