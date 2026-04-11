// File: lib/widgets/challenge/math_challenge.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../style/buttons.dart';
import '../../style/cards.dart';
import '../../style/textfield.dart';

enum DifficultySettings {
  easy,
  medium,
  hard,
}

class MathChallengeWidget extends StatefulWidget {
  final VoidCallback onSuccess;
  final DifficultySettings difficulty;

  const MathChallengeWidget({
    super.key,
    required this.onSuccess,
    this.difficulty = DifficultySettings.easy,
  });

  @override
  State<MathChallengeWidget> createState() => _MathChallengeWidgetState();
}

class _MathChallengeWidgetState extends State<MathChallengeWidget> {
  late int _num1;
  late int _num2;
  late String _operator;
  late int _correctAnswer;
  final TextEditingController _answerController = TextEditingController();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateNewChallenge();
  }

  void _generateNewChallenge() {
    try {
      switch (widget.difficulty) {
        case DifficultySettings.easy:
          _operator = _random.nextBool() ? '+' : '-';
          _num1 = _random.nextInt(50) + 1;
          _num2 = _random.nextInt(50) + 1;
          if (_operator == '-' && _num1 < _num2) {
            final temp = _num1;
            _num1 = _num2;
            _num2 = temp;
          }
          break;
        case DifficultySettings.medium:
          _operator = '*';
          _num1 = _random.nextInt(12) + 1;
          _num2 = _random.nextInt(12) + 1;
          break;
        case DifficultySettings.hard:
          _operator = _random.nextBool() ? '+' : '-';
          _num1 = _random.nextInt(100) + 20;
          _num2 = _random.nextInt(50) + 10;
          final int num3 = _random.nextInt(20) + 1;
          if (_operator == '-') {
            _correctAnswer = _num1 - _num2 + num3;
          } else {
            _correctAnswer = _num1 + _num2 * num3;
          }
          break;
      }

      if (widget.difficulty != DifficultySettings.hard) {
        switch (_operator) {
          case '+':
            _correctAnswer = _num1 + _num2;
            break;
          case '-':
            _correctAnswer = _num1 - _num2;
            break;
          case '*':
            _correctAnswer = _num1 * _num2;
            break;
        }
      }

      _answerController.clear();
    } catch (e) {
      debugPrint('Error generating math challenge: $e');
    }
  }

  void _validateAnswer() {
    try {
      final input = int.tryParse(_answerController.text.trim());
      if (input == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid number')),
        );
        return;
      }

      if (input == _correctAnswer) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Continuing to app')),
        );
        widget.onSuccess.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect answer, try again')),
        );
        _generateNewChallenge();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error validating answer: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Solve the math challenge',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.difficulty == DifficultySettings.hard
                        ? '$_num1 $_operator $_num2 * ${_random.nextInt(20) + 1}'
                        : '$_num1 $_operator $_num2 = ?',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassTextField(
              controller: _answerController,
              hintText: 'Write Answer',
              keyboardType: TextInputType.number,
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            GlassPrimaryElevatedButton(
              onPressed: _validateAnswer,
              label: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}

