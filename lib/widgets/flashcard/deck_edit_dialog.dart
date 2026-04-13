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
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: 'Save',
          onPressed: _save,
        ),
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
