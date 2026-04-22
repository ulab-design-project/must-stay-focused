// File: lib/widgets/flashcard/deck_selector_dialog.dart
// Simple Searchable Deck Selector Dialog
//
// A lightweight dialog for selecting a deck without edit/create functionality.
// Used within FlashCardEditDialog for simple deck selection.

import 'package:flutter/material.dart';

import '../../data/models/flash_card.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../style/dialogs.dart';
import '../../style/forms.dart';
import '../../style/list_tile.dart';
import '../../style/theme.dart';

/// A simple searchable dialog for selecting a deck.
/// Does not include edit or create functionality - just selection.
class DeckSelectorDialog extends StatefulWidget {
  final Deck? selectedDeck;

  const DeckSelectorDialog({super.key, this.selectedDeck});

  @override
  State<DeckSelectorDialog> createState() => _DeckSelectorDialogState();
}

class _DeckSelectorDialogState extends State<DeckSelectorDialog> {
  String _searchQuery = '';
  List<Deck> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  /// Loads all decks from the database.
  Future<void> _loadDecks() async {
    _decks = await flashcardRepo.getAllDecks();
    if (mounted) setState(() => _isLoading = false);
  }

  /// Filters decks based on search query.
  List<Deck> get _filteredDecks {
    if (_searchQuery.isEmpty) return _decks;
    return _decks
        .where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassDialog(
      maxWidth: 360,
      title: 'Select Deck',
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassTextField(
            placeholder: 'Search...',
            prefixIcon: Icon(
              Icons.search,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              size: 18,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: AppElementSizes.spacingSm),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(AppElementSizes.spacingLg),
              child: CircularProgressIndicator(),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredDecks.length,
                itemBuilder: (ctx, i) {
                  final deck = _filteredDecks[i];
                  final isSelected = deck.id == widget.selectedDeck?.id;
                  return GlassListTile(
                    title: Text(
                      deck.name,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: theme.colorScheme.primary)
                        : null,
                    onTap: () => Navigator.pop(ctx, deck),
                    isLast: i == _filteredDecks.length - 1,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
