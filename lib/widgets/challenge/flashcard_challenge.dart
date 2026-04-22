import 'dart:math';

import 'package:flutter/material.dart';
import 'package:must_stay_focused/style/containers.dart';
import 'package:must_stay_focused/style/forms.dart';
import '../../data/models/flash_card.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../utils/theme_helpers.dart';
import '../../style/buttons.dart';
import '../../style/theme.dart';
import '../flashcard/deck_selector.dart';

class FlashcardChallengeWidget extends StatefulWidget {
  final VoidCallback onSolved;

  const FlashcardChallengeWidget({super.key, required this.onSolved});

  @override
  State<FlashcardChallengeWidget> createState() =>
      _FlashcardChallengeWidgetState();
}

class _FlashcardChallengeWidgetState extends State<FlashcardChallengeWidget> {
  final TextEditingController _answerController = TextEditingController();
  final Random _random = Random();

  Deck? _selectedDeck;
  FlashCard? _currentCard;
  bool _isLoading = true;
  bool _isReloadingCard = false;
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadDecks() async {
    try {
      final allDecks = await flashcardRepo.getAllDecks();
      if (!mounted) {
        return;
      }

      setState(() {
        if (allDecks.isEmpty) {
          _selectedDeck = null;
        } else {
          final currentId = _selectedDeck?.id;
          Deck? retained;
          if (currentId != null) {
            for (final deck in allDecks) {
              if (deck.id == currentId) {
                retained = deck;
                break;
              }
            }
          }
          _selectedDeck = retained ?? allDecks.first;
        }
      });

      await _loadRandomCard();
    } catch (e, stackTrace) {
      debugPrint('FlashcardChallengeWidget _loadDecks error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRandomCard() async {
    try {
      final selectedDeck = _selectedDeck;
      if (selectedDeck == null) {
        if (mounted) {
          setState(() {
            _currentCard = null;
            _isLoading = false;
          });
        }
        return;
      }

      final cards = await flashcardRepo.getFilteredDeck(
        deckName: selectedDeck.name,
        showFullDeck: true,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentCard = cards.isEmpty
            ? null
            : cards[_random.nextInt(cards.length)];
        _answerController.clear();
        _isSolved = false;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('FlashcardChallengeWidget _loadRandomCard error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onDeckSelected(Deck deck) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedDeck = deck;
      _isLoading = true;
    });

    await _loadRandomCard();
  }

  Future<void> _reloadCurrentCard() async {
    if (_isLoading || _isReloadingCard) {
      return;
    }

    setState(() {
      _isReloadingCard = true;
    });

    try {
      await _loadRandomCard();
    } finally {
      if (mounted) {
        setState(() {
          _isReloadingCard = false;
        });
      }
    }
  }

  String _normalizedAnswer(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  bool _matchesAnswer({required String expected, required String answer}) {
    final normalizedExpected = _normalizedAnswer(expected);
    final normalizedAnswer = _normalizedAnswer(answer);

    return normalizedExpected == normalizedAnswer;
  }

  void _checkAnswer() {
    final card = _currentCard;
    if (card == null) {
      return;
    }

    try {
      final answer = _answerController.text.trim();
      if (answer.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your answer.')),
        );
        return;
      }

      final isCorrect = _matchesAnswer(expected: card.back, answer: answer);

      if (isCorrect) {
        if (!_isSolved) {
          widget.onSolved();
        }

        setState(() {
          _isSolved = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correct answer. You can submit now.')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect answer. Try again or reload a card.'),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('FlashcardChallengeWidget _checkAnswer error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final cardWidth = getScreenWidth(context) * 0.5;

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(AppElementSizes.spacingLg),
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Deck:',
              style: TextStyle(color: onSurface, fontSize: AppTextSizes.body),
            ),
            const SizedBox(width: AppElementSizes.spacingSm),
            DeckSelector(
              width: 170,
              selectedDeck: _selectedDeck,
              onDeckSelected: (deck) {
                _onDeckSelected(deck);
              },
              onDeckChanged: _loadDecks,
            ),
            const SizedBox(width: AppElementSizes.spacingSm),
            GlassSquircleIconButton(
              size: AppElementSizes.buttonSquare,
              onPressed: _reloadCurrentCard,
              icon: _isReloadingCard
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: onSurface,
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      size: AppElementSizes.icon,
                      color: onSurface,
                    ),
            ),
          ],
        ),
        const SizedBox(height: AppElementSizes.spacingMd),
        GlassCard(
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.all(AppElementSizes.spacingLg),
            alignment: Alignment.center,
            child: Text(
              _currentCard?.front ?? 'No cards in this deck.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onSurface,
                fontSize: AppTextSizes.title,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppElementSizes.spacingMd),
        SizedBox(
          width: 200,
          child: GlassTextField(
            controller: _answerController,
            textStyle: TextStyle(color: onSurface),
            placeholder: 'Write Answer',
          ),
        ),
        const SizedBox(height: AppElementSizes.spacingMd),
        GlassSquircleButton(
          width: 100,
          isPrimary: true,
          onPressed: _currentCard == null ? null : _checkAnswer,
          child: Text('Submit', style: TextStyle(color: onSurface)),
        ),
      ],
    );
  }
}
