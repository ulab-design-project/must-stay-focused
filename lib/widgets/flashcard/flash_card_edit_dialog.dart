import 'package:flutter/material.dart';

import 'package:must_stay_focused/style/dialogs.dart';
import 'package:must_stay_focused/style/forms.dart';
import 'package:must_stay_focused/style/picker.dart';
import 'package:must_stay_focused/style/theme.dart';

import '../../data/models/flash_card.dart';
import '../../data/repositories/flashcard_repository.dart';
import 'deck_selector_dialog.dart';

class FlashCardEditDialog extends StatefulWidget {
  final FlashCard? existingCard;
  final Deck? selectedDeck;

  const FlashCardEditDialog({super.key, this.existingCard, this.selectedDeck});

  @override
  State<FlashCardEditDialog> createState() => _FlashCardEditDialogState();
}

class _FlashCardEditDialogState extends State<FlashCardEditDialog> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();

  Deck? _selectedDeck;

  @override
  void initState() {
    super.initState();
    _selectedDeck = widget.selectedDeck ?? widget.existingCard?.deck.value;
    if (widget.existingCard != null) {
      _frontController.text = widget.existingCard!.front;
      _backController.text = widget.existingCard!.back;
    }
  }

  Future<void> _save() async {
    if (_frontController.text.isEmpty || _backController.text.isEmpty) return;

    if (_selectedDeck == null) return;

    final card =
        widget.existingCard ??
        FlashCard.make(
          front: _frontController.text,
          back: _backController.text,
          deck: _selectedDeck!,
          creationDate: DateTime.now(),
        );

    card.front = _frontController.text;
    card.back = _backController.text;
    card.deck.value = _selectedDeck;

    await flashcardRepo.upsertFlashCard(card);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _showDeckSelector() async {
    final selected = await showDialog<Deck>(
      context: context,
      builder: (ctx) => DeckSelectorDialog(selectedDeck: _selectedDeck),
    );
    if (selected != null) {
      setState(() => _selectedDeck = selected);
    }
  }

  Future<void> _delete() async {
    try {
      if (widget.existingCard == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      final shouldDelete = await showDialog<bool>(
        context: context,
        builder: (context) => GlassDialog(
          title: 'Delete Flashcard?',
          content: const Text(
            'This action cannot be undone.',
            textAlign: TextAlign.center,
          ),
          actions: [
            GlassDialogAction(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context, false),
            ),
            GlassDialogAction(
              label: 'Delete',
              isDestructive: true,
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (shouldDelete != true) return;

      await flashcardRepo.deleteFlashCard(widget.existingCard!.id);
      if (mounted) Navigator.pop(context);
    } catch (error, stackTrace) {
      debugPrint('Failed to delete flashcard: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete flashcard. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassDialog(
      title: widget.existingCard == null
          ? 'Create Flashcard'
          : 'Edit Flashcard',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppElementSizes.spacingMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Deck',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.88,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                GlassPicker(
                  width: 160,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  value: _selectedDeck?.name ?? 'Default',
                  textStyle: TextStyle(
                    fontSize: AppTextSizes.small,
                    color: theme.colorScheme.onSurface,
                  ),
                  placeholderStyle: TextStyle(
                    fontSize: AppTextSizes.small,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                  icon: Icon(
                    Icons.expand_more,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                  onTap: _showDeckSelector,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppElementSizes.spacingMd),
          GlassTextField(
            controller: _frontController,
            placeholder: 'Front (Question)',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          GlassTextField(
            controller: _backController,
            placeholder: 'Back (Answer)',
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: widget.existingCard != null ? 'Delete' : 'Cancel',
          isDestructive: widget.existingCard != null,
          onPressed: () =>
              widget.existingCard != null ? _delete() : Navigator.pop(context),
        ),
        GlassDialogAction(label: 'Save', onPressed: _save, isPrimary: true),
      ],
    );
  }
}
