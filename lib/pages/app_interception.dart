// File: lib/pages/app_interception.dart
// TODO: Implement App Interception Overlay
// Architecture: Needs to run as a fast-loading full-screen overlay in under 500ms (NFR-01).
// Classes to implement:
// 1. `class AppInterceptionScreen extends StatelessWidget`:
//    - UI: Full-screen modal that covers the intercepted blocked app (FR-07).
//    - State/Dependencies: Fetch data via `TaskRepository` and `ChallengeFactory`.
//    - Layout:
//      - Top section: Display Top 3 Sorted Tasks (prioritizing 'Critical') without scrolling (FR-15, FR-16).
//        - Add checkboxes to map to direct task completion (FR-17).
//      - Middle section: Render `UnlockChallengeWidget` dynamically chosen based on preferred type (Math, Flashcard) (FR-24, FR-25).
//      - Bottom section: 
//        - "Unlock for 15 mins" option appearing upon challenge success (FR-30, FR-28).
//        - "Postpone 5 min" button (autonomy preserving) bypassing the challenge temporarily (FR-29).
