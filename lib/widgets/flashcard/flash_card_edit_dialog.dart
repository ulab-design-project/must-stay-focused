import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../data/models/flash_card.dart';
import '../../data/repositories/flashcard_repository.dart';

class FlashCardEditDialog extends StatefulWidget {
  final FlashCard? existingCard;
  final Deck? deck;

  const FlashCardEditDialog({super.key, this.existingCard, this.deck});

  @override
  State<FlashCardEditDialog> createState() => _FlashCardEditDialogState();
}

class _FlashCardEditDialogState extends State<FlashCardEditDialog> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      _frontController.text = widget.existingCard!.front;
      _backController.text = widget.existingCard!.back;
    }
  }

  Future<void> _save() async {
    if (_frontController.text.isEmpty || _backController.text.isEmpty) return;
    
    Deck? attachedDeck = widget.deck ?? widget.existingCard?.deck.value;
    if (attachedDeck == null) return; 

    final card = widget.existingCard ?? FlashCard.make(
      front: _frontController.text,
      back: _backController.text,
      deck: attachedDeck,
      creationDate: DateTime.now(),
    );
    
    card.front = _frontController.text;
    card.back = _backController.text;
    
    await flashcardRepo.upsertFlashCard(card);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: widget.existingCard == null ? 'Create Flashcard' : 'Edit Flashcard',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          label: 'Save',
          onPressed: _save,
          isPrimary: true,
        ),
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
