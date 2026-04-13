import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../data/models/flash_card.dart';
import '../../data/repositories/flashcard_repository.dart';

class DeckEditDialog extends StatefulWidget {
  final Deck? existingDeck;

  const DeckEditDialog({super.key, this.existingDeck});

  @override
  State<DeckEditDialog> createState() => _DeckEditDialogState();
}

class _DeckEditDialogState extends State<DeckEditDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingDeck != null) {
      _nameController.text = widget.existingDeck!.name;
      _descController.text = widget.existingDeck!.description ?? '';
    }
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) return;
    final deck = widget.existingDeck ?? Deck();
    deck.name = _nameController.text;
    deck.description = _descController.text;
    await flashcardRepo.upsertDeck(deck);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (widget.existingDeck == null) return;
    if (widget.existingDeck!.name == 'Default') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Can't delete default deck")),
        );
      }
      return;
    }

    final merge = await GlassDialog.show<bool>(
      context: context,
      title: 'Delete Deck',
      message: 'Move cards to Default deck?',
      actions: [
        GlassDialogAction(
          label: 'Delete',
          isDestructive: true,
          onPressed: () => Navigator.pop(context, false),
        ),
        GlassDialogAction(
          label: 'Move',
          isPrimary: true,
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (merge == null) return;

    try {
      await flashcardRepo.deleteDeck(
        widget.existingDeck!,
        mergeToDefault: merge,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: widget.existingDeck == null ? 'Create Deck' : 'Edit Deck',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassTextField(
            controller: _nameController,
            placeholder: 'Name',
          ),
          const SizedBox(height: 12),
          GlassTextField(
            controller: _descController,
            placeholder: 'Description',
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        if (widget.existingDeck != null)
          GlassDialogAction(
            label: 'Delete',
            isDestructive: true,
            onPressed: _delete,
          ),
        GlassDialogAction(
          label: 'Save',
          isPrimary: true,
          onPressed: _save,
        ),
      ],
    );
  }
}
