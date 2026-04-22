import 'package:flutter/material.dart';
import 'package:must_stay_focused/style/dialogs.dart';
import 'package:must_stay_focused/style/forms.dart';
import 'package:must_stay_focused/style/picker.dart';
import 'dart:async';

import '../../data/models/flash_card.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../style/theme.dart';
import 'deck_edit_dialog.dart';

class DeckSelector extends StatefulWidget {
  final Deck? selectedDeck;
  final ValueChanged<Deck> onDeckSelected;
  final VoidCallback? onDeckChanged;
  final double width;

  const DeckSelector({
    super.key,
    this.selectedDeck,
    required this.onDeckSelected,
    this.onDeckChanged,
    this.width = 120,
  });

  @override
  State<DeckSelector> createState() => _DeckSelectorState();
}

class _DeckSelectorState extends State<DeckSelector> {
  List<Deck> _allDecks = [];
  String _searchQuery = '';
  StreamSubscription<List<Deck>>? _decksSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToDecks();
  }

  @override
  void dispose() {
    _decksSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToDecks() {
    _decksSubscription = flashcardRepo.watchDecks().listen((decks) {
      if (!mounted) {
        return;
      }

      setState(() {
        _allDecks = decks;
      });
    });
  }

  Future<void> _loadDecks() async {
    _allDecks = await flashcardRepo.getAllDecks();
    if (mounted) setState(() {});
  }

  void _openEditDialog({Deck? deck}) async {
    await showDialog(
      context: context,
      builder: (ctx) => DeckEditDialog(existingDeck: deck),
    );
    await _loadDecks();
    widget.onDeckChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fallback if empty, but still show the picker to open dropdown which has "New Deck" button
    final valueName =
        widget.selectedDeck?.name ??
        (_allDecks.isEmpty ? 'No Decks' : 'Select Deck');

    return GlassPicker(
      width: widget.width,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      value: valueName,
      textStyle: TextStyle(
        fontSize: AppTextSizes.small,
        color: theme.colorScheme.onSurface,
      ),
      placeholder: 'Select Deck',
      placeholderStyle: TextStyle(
        fontSize: AppTextSizes.small,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
      ),
      icon: Icon(
        Icons.expand_more,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
      ),
      onTap: () => _showDropdown(context),
    );
  }

  void _showDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        _searchQuery = '';
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filtered = _allDecks
                .where(
                  (d) =>
                      d.name.toLowerCase().contains(_searchQuery.toLowerCase()),
                )
                .toList();
            return GlassDialog(
              title: 'Select Deck',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassTextField(
                    placeholder: 'Search decks...',
                    placeholderStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    onChanged: (v) => setStateDialog(() => _searchQuery = v),
                  ),
                  const SizedBox(height: AppElementSizes.spacingMd),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (c, i) {
                        final deck = filtered[i];
                        return ListTile(
                          title: Text(
                            deck.name,
                            style: TextStyle(
                              color: Theme.of(ctx).colorScheme.onSurface,
                            ),
                          ),
                          onTap: () {
                            widget.onDeckSelected(deck);
                            Navigator.pop(ctx);
                          },
                          trailing: deck.name == 'Default'
                              ? null
                              : IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Theme.of(ctx).colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _openEditDialog(deck: deck);
                                  },
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                GlassDialogAction(
                  label: 'New Deck',
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openEditDialog();
                  },
                ),
                GlassDialogAction(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
