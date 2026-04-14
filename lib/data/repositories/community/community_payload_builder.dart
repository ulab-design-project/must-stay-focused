import '../../models/flash_card.dart';
import '../../models/task.dart';
import '../flashcard_repository.dart';
import '../task_repository.dart';

class CommunityPayloadBuilder {
  Future<Map<String, dynamic>> buildTaskListPayload(TaskList taskList) async {
    try {
      final tasks = await taskRepo.getTasksByListName(taskList.name);
      return {
        'tasks': tasks
            .map(
              (task) => {
                'title': task.title,
                'description': task.description,
                'priority': task.priority.name,
                'start_time': task.startTime?.toIso8601String(),
                'end_time': task.endTime?.toIso8601String(),
                'days': task.days,
              },
            )
            .toList(),
      };
    } catch (e, stackTrace) {
      throw Exception(
        'CommunityPayloadBuilder buildTaskListPayload failed: $e\n$stackTrace',
      );
    }
  }

  Future<Map<String, dynamic>> buildFlashCardPayload(Deck deck) async {
    try {
      final cards = await flashcardRepo.getFilteredDeck(
        deckName: deck.name,
        sortBy: 'creationTime',
        isAscending: true,
        showFullDeck: true,
      );

      return {
        'cards': cards
            .map((card) => {'front': card.front, 'back': card.back})
            .toList(),
      };
    } catch (e, stackTrace) {
      throw Exception(
        'CommunityPayloadBuilder buildFlashCardPayload failed: $e\n$stackTrace',
      );
    }
  }
}
