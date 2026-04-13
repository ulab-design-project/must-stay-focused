// File: lib/data/db/initial_data.dart
// Initial Data Setup for Isar Database
//
// This file contains all functions for creating default data in the database.
// Called automatically during IsarService initialization.

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../models/task.dart';
import '../models/flash_card.dart';
import 'isar_service.dart';

/// Creates the default task list and sample tasks if they don't exist.
/// Called automatically during IsarService init().
Future<void> prepareDefaultData() async {
  // Check if default list already exists
  final existingDefault = await idb.taskLists.filter().nameEqualTo('Default').findFirst();
  
  if (existingDefault != null) return;

  await idb.writeTxn(() async {
    // Create default list
    final defaultList = TaskList()
      ..name = 'Default'
      ..iconCodePoint = Icons.list.codePoint
      ..isDefault = true;
    await idb.taskLists.put(defaultList);

    // Sample task 1: Low priority, no time
    final task1 = Task()
      ..title = 'Read a book chapter'
      ..description = 'Finish chapter 5 of the current book'
      ..priority = TaskPriority.low
      ..creationTime = DateTime.now()
      ..isCompleted = false
      ..isArchived = false;
    task1.taskList.value = defaultList;
    await idb.tasks.put(task1);
    await task1.taskList.save();

    // Sample task 2: Medium priority with time range
    final task2 = Task()
      ..title = 'Team meeting'
      ..description = 'Weekly sync with the team'
      ..priority = TaskPriority.medium
      ..startTime = DateTime.now().copyWith(hour: 10, minute: 0)
      ..endTime = DateTime.now().copyWith(hour: 11, minute: 0)
      ..creationTime = DateTime.now()
      ..isCompleted = false
      ..isArchived = false;
    task2.taskList.value = defaultList;
    await idb.tasks.put(task2);
    await task2.taskList.save();

    // Sample task 3: High priority, critical
    final task3 = Task()
      ..title = 'Submit project report'
      ..description = 'Final report for Q4 deliverables'
      ..priority = TaskPriority.high
      ..startTime = DateTime.now().copyWith(hour: 17, minute: 0)
      ..creationTime = DateTime.now()
      ..isCompleted = false
      ..isArchived = false;
    task3.taskList.value = defaultList;
    await idb.tasks.put(task3);
    await task3.taskList.save();

    // Sample task 4: Critical priority, recurring Mon/Wed/Fri
    final task4 = Task()
      ..title = 'Daily standup'
      ..description = 'Quick status update'
      ..priority = TaskPriority.critical
      ..startTime = DateTime.now().copyWith(hour: 9, minute: 30)
      ..days = [1, 3, 5] // Mon, Wed, Fri
      ..creationTime = DateTime.now()
      ..isCompleted = false
      ..isArchived = false;
    task4.taskList.value = defaultList;
    await idb.tasks.put(task4);
    await task4.taskList.save();

    // Sample task 5: Completed task
    final task5 = Task()
      ..title = 'Setup development environment'
      ..description = 'Install all required tools'
      ..priority = TaskPriority.medium
      ..creationTime = DateTime.now().subtract(const Duration(days: 2))
      ..completionTime = DateTime.now().subtract(const Duration(days: 1))
      ..isCompleted = true
      ..isArchived = false;
    task5.taskList.value = defaultList;
    await idb.tasks.put(task5);
    await task5.taskList.save();

    // ------------------------------------
    // Flashcard Decks
    // ------------------------------------

    // 1) Default Deck
    final defaultDeck = Deck()
      ..name = 'Default'
      ..description = 'Default flashcard deck';
    await idb.decks.put(defaultDeck);

    // 2) Organic Chemistry Deck
    final orgChemDeck = Deck()
      ..name = 'Organic Chemistry'
      ..description = 'Organic Chemistry Formulas';
    await idb.decks.put(orgChemDeck);

    final orgChemCards = [
      {'f': 'Benzene', 'b': 'C6H6'},
      {'f': 'Methane', 'b': 'CH4'},
      {'f': 'Ethane', 'b': 'C2H6'},
      {'f': 'Propane', 'b': 'C3H8'},
      {'f': 'Butane', 'b': 'C4H10'},
      {'f': 'Pentane', 'b': 'C5H12'},
      {'f': 'Ethene', 'b': 'C2H4'},
      {'f': 'Ethyne', 'b': 'C2H2'},
      {'f': 'Methanol', 'b': 'CH3OH'},
      {'f': 'Ethanol', 'b': 'C2H5OH'},
    ];

    for (var c in orgChemCards) {
      final fc = FlashCard.make(
        front: c['f']!,
        back: c['b']!,
        deck: orgChemDeck,
        creationDate: DateTime.now(),
      );
      await idb.flashCards.put(fc);
      await fc.deck.save();
    }

    // 3) Physics Deck
    final physDeck = Deck()
      ..name = 'Physics'
      ..description = 'Physics Equations';
    await idb.decks.put(physDeck);

    final physCards = [
      {'f': 'Newton\'s Second Law', 'b': 'F = ma'},
      {'f': 'Mass-Energy Equivalence', 'b': 'E = mc²'},
      {'f': 'Ohm\'s Law', 'b': 'V = IR'},
      {'f': 'Kinetic Energy', 'b': 'KE = 1/2 mv²'},
      {'f': 'Potential Energy', 'b': 'PE = mgh'},
      {'f': 'Ideal Gas Law', 'b': 'PV = nRT'},
      {'f': 'Wave Equation', 'b': 'v = fλ'},
      {'f': 'Hooke\'s Law', 'b': 'F = -kx'},
      {'f': 'Law of Universal Gravitation', 'b': 'F = G(m1m2)/r²'},
      {'f': 'Work', 'b': 'W = Fd cos(θ)'},
    ];

    for (var c in physCards) {
      final fc = FlashCard.make(
        front: c['f']!,
        back: c['b']!,
        deck: physDeck,
        creationDate: DateTime.now(),
      );
      await idb.flashCards.put(fc);
      await fc.deck.save();
    }
  });
}
