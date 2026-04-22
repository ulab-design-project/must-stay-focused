import 'dart:async';

import 'package:flutter/material.dart';
import 'package:must_stay_focused/style/containers.dart';
import 'package:must_stay_focused/style/list_tile.dart';
import 'package:must_stay_focused/style/picker.dart';

import '../../data/models/flash_card.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../style/theme.dart';
import '../../utils/theme_helpers.dart';
import '../../style/buttons.dart';
import 'deck_selector.dart';
import 'flash_card.dart';
import 'flash_card_edit_dialog.dart';

class FlashCardCarousel extends StatefulWidget {
  const FlashCardCarousel({super.key});

  @override
  State<FlashCardCarousel> createState() => _FlashCardCarouselState();
}

class _FlashCardCarouselState extends State<FlashCardCarousel> {
  Deck? _selectedDeck;
  List<FlashCard> _cards = [];
  bool _hasAnyCardsInDeck = false;
  bool _showFullDeck = false;
  String _sortBy = 'sm2';
  bool _isAscending = true;
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _loadInitialDeck();
  }

  Future<void> _loadInitialDeck() async {
    final decks = await flashcardRepo.getAllDecks();
    if (decks.isNotEmpty) {
      if (mounted) setState(() => _selectedDeck = decks.first);
      _loadCards();
      return;
    }

    if (mounted) {
      setState(() {
        _selectedDeck = null;
        _cards = [];
        _hasAnyCardsInDeck = false;
      });
    }
  }

  Future<void> _loadCards() async {
    if (_selectedDeck == null) {
      if (mounted) {
        setState(() {
          _cards = [];
          _hasAnyCardsInDeck = false;
        });
      }
      return;
    }

    final fullDeckCards = await flashcardRepo.getFilteredDeck(
      deckName: _selectedDeck!.name,
      sortBy: _sortBy,
      isAscending: _isAscending,
      showFullDeck: true,
    );

    final cards = await flashcardRepo.getFilteredDeck(
      deckName: _selectedDeck!.name,
      sortBy: _sortBy,
      isAscending: _isAscending,
      showFullDeck: _showFullDeck,
    );

    if (mounted) {
      setState(() {
        _cards = cards;
        _hasAnyCardsInDeck = fullDeckCards.isNotEmpty;
      });
    }
  }

  Future<void> _toggleDeckMode() async {
    setState(() => _showFullDeck = !_showFullDeck);
    await _loadCards();
  }

  Widget _buildDeckModeButton(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppElementSizes.spacingLg,
        ),
        child: GlassCard(
          isPrimary: true,
          child: TextButton(
            onPressed: _toggleDeckMode,
            child: Text(
              _showFullDeck ? 'Show Today' : 'Show All',
              style: TextStyle(color: theme.colorScheme.surface),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSortPicker() async {
    try {
      final selected = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final options = [
            ('Creation Date', 'creationTime'),
            ('Smart Review', 'sm2'),
          ];
          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(ctx).padding.bottom + AppElementSizes.spacingMd,
              left: AppElementSizes.spacingMd,
              right: AppElementSizes.spacingMd,
            ),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((option) {
                  final isSelected = _sortBy == option.$2;
                  return GlassListTile(
                    leading: isSelected
                        ? const Icon(Icons.check_circle, size: 20)
                        : const SizedBox(width: 20),
                    title: Text(
                      option.$1,
                      style: TextStyle(
                        color: Theme.of(ctx).colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(ctx).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.pop(ctx, option.$2),
                    isLast: option == options.last,
                  );
                }).toList(),
              ),
            ),
          );
        },
      );

      if (selected == null || !mounted) return;

      setState(() => _sortBy = selected);
      await _loadCards();
    } catch (e, stackTrace) {
      debugPrint('FlashCardCarousel _openSortPicker error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = getScreenHeight(context) * 0.2;

    final theme = Theme.of(context);
    return SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {}, // Blocks touches from passing through manually
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppElementSizes.spacingSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min, // Constrains it to natural height
            children: [
              Row(
                children: [
                  if (!_isCollapsed) ...[
                    GlassSquircleIconButton(
                      onPressed: () {
                        if (_selectedDeck != null) {
                          showDialog(
                            context: context,
                            builder: (ctx) =>
                                FlashCardEditDialog(deck: _selectedDeck),
                          ).then((_) => _loadCards());
                        }
                      },
                      icon: Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      isPrimary: false,
                    ),
                    const SizedBox(width: AppElementSizes.spacingSm),
                    Expanded(
                      child: DeckSelector(
                        width: 200, // Let it expand inside Expanded
                        selectedDeck: _selectedDeck,
                        onDeckSelected: (d) {
                          setState(() {
                            _selectedDeck = d;
                            _showFullDeck = false; // reset on deck change
                          });
                          _loadCards();
                        },
                        onDeckChanged: _loadInitialDeck,
                      ),
                    ),
                    const SizedBox(width: AppElementSizes.spacingSm),
                    GlassPicker(
                      width:
                          80, // Give sufficient rigid space for text rendering
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      value: _sortBy == 'sm2' ? 'SM2' : 'Creation Date',
                      placeholder: 'Sort',
                      textStyle: TextStyle(
                        fontSize: AppTextSizes.small,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      icon: Icon(
                        Icons.expand_more,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                      onTap: _openSortPicker,
                    ),
                    const SizedBox(width: AppElementSizes.spacingSm),
                    GlassSquircleIconButton(
                      onPressed: () {
                        setState(() => _isAscending = !_isAscending);
                        _loadCards();
                      },
                      icon: Icon(
                        _isAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: AppElementSizes.spacingSm),
                  ] else ...[
                    const Spacer(),
                  ],
                  GlassSquircleIconButton(
                    onPressed: () =>
                        setState(() => _isCollapsed = !_isCollapsed),
                    icon: Icon(
                      _isCollapsed
                          ? Icons.card_membership
                          : Icons.keyboard_arrow_down,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (!_isCollapsed) ...[
                const SizedBox(height: AppElementSizes.spacingSm),
                GlassCard(
                  child: SizedBox(
                    height: height,
                    child: _cards.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _showFullDeck
                                      ? 'No cards found.'
                                      : 'No cards due. Show all or add new.',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                if (_hasAnyCardsInDeck) ...[
                                  const SizedBox(
                                    height: AppElementSizes.spacingMd,
                                  ),
                                  _buildDeckModeButton(context),
                                ],
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                _cards.length + 1, // +1 for the end button
                            itemBuilder: (context, index) {
                              if (index == _cards.length) {
                                if (!_hasAnyCardsInDeck) {
                                  return const SizedBox.shrink();
                                }

                                return _buildDeckModeButton(context);
                              }
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: AppElementSizes.spacingMd,
                                ),
                                child: FlashCardWidget(
                                  key: ValueKey(_cards[index].id),
                                  card: _cards[index],
                                  onRated: _loadCards,
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
