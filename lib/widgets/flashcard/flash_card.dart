import 'dart:ui';

import 'package:flutter/material.dart';
import '../../data/models/flash_card.dart';
import '../../data/repositories/flashcard_repository.dart';
import '../../style/theme.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'dart:math' as math;

import 'flash_card_edit_dialog.dart';
import '../../utils/theme_helpers.dart';

class FlashCardWidget extends StatefulWidget {
  final FlashCard card;
  final VoidCallback onRated;

  const FlashCardWidget({super.key, required this.card, required this.onRated});

  @override
  State<FlashCardWidget> createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFront = true;

  Offset _panOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    setState(() {
      _isFront = !_isFront;
      if (_isFront) {
        _flipController.reverse();
      } else {
        _flipController.forward();
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _panOffset += details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) async {
    if (_panOffset.distance > 80) {
      String difficulty = 'medium';

      if (_panOffset.dx < 0 && _panOffset.dy < 0) {
        difficulty = 'easy'; // Top-Left: Green
      } else if (_panOffset.dx > 0 && _panOffset.dy < 0) {
        difficulty = 'medium'; // Top-Right: Yellow
      } else if (_panOffset.dx < 0 && _panOffset.dy > 0) {
        difficulty = 'hard'; // Bottom-Left: Orange
      } else if (_panOffset.dx > 0 && _panOffset.dy > 0) {
        difficulty =
            'hard'; // Bottom-Right: Forgot/Hard (the SM2 expects easy, medium, hard. Quality 2 logic will execute if "forgot" string breaks SM2 switch case but it's handled below)
        difficulty = 'forgot';
      }

      widget.card.updateSM2data(difficulty);
      widget.card.calculateSM2ReviewDate();
      await flashcardRepo.upsertFlashCard(widget.card);
      widget.onRated();

      setState(() {
        _panOffset = Offset.zero;
        _isFront = true;
        _flipController.value = 0.0;
      });
    } else {
      setState(() {
        _panOffset = Offset.zero;
      });
    }
  }

  _SwipeFeedback? _getSwipeFeedback(ThemeData theme) {
    if (_panOffset.distance < 20) return null;

    if (_panOffset.dx < 0 && _panOffset.dy < 0) {
      return _SwipeFeedback(
        label: 'Easy',
        color: Colors.green.withValues(alpha: 0.50),
        gradientCenter: const Alignment(-0.9, -0.9),
        labelAtTop: false,
      );
    } else if (_panOffset.dx > 0 && _panOffset.dy < 0) {
      return _SwipeFeedback(
        label: 'Medium',
        color: Colors.amber.withValues(alpha: 0.50),
        gradientCenter: const Alignment(0.9, -0.9),
        labelAtTop: false,
      );
    } else if (_panOffset.dx < 0 && _panOffset.dy > 0) {
      return _SwipeFeedback(
        label: 'Hard',
        color: Colors.orange.withValues(alpha: 0.50),
        gradientCenter: const Alignment(-0.9, 0.9),
        labelAtTop: true,
      );
    } else if (_panOffset.dx > 0 && _panOffset.dy > 0) {
      return _SwipeFeedback(
        label: 'Forgot',
        color: Colors.red.withValues(alpha: 0.50),
        gradientCenter: const Alignment(0.9, 0.9),
        labelAtTop: true,
      );
    }
    return null;
  }

  Widget _buildSwipeOverlay(
    ThemeData theme,
    _SwipeFeedback feedback,
    double cardWidth,
    bool isFlipped,
  ) {
    final labelX = _panOffset.dx < 0 ? -0.78 : 0.78;
    final labelY = feedback.labelAtTop ? -0.84 : 0.84;

    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppElementSizes.cardRadius),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..rotateY(isFlipped ? math.pi : 0.0),
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: themeController.glassBlur, sigmaY: themeController.glassBlur),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: feedback.gradientCenter,
                        radius: 1.05,
                        colors: [
                          feedback.color,
                          feedback.color.withValues(alpha: 0.20),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(labelX, labelY),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppElementSizes.spacingSm,
                    vertical: 4,
                  ),
                  constraints: BoxConstraints(maxWidth: cardWidth * 0.55),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                  child: Text(
                    feedback.label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppTextSizes.small,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth = getScreenWidth(context) * 0.4;
    final swipeFeedback = _getSwipeFeedback(theme);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleFlip,
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => FlashCardEditDialog(existingCard: widget.card),
        ).then((_) {
          // Notify the parent carousel to reload the cards (e.g. if edited or deleted)
          widget.onRated();
        });
      },
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: () {
        setState(() {
          _panOffset = Offset.zero;
        });
      },
      child: Transform.translate(
        offset: _panOffset,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final angle = _flipAnimation.value * math.pi;
            final isFlipped = angle > math.pi / 2;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle);
            final glassColor = isFlipped
                ? theme.colorScheme.secondary.withValues(alpha: 0.26)
                : theme.colorScheme.primary.withValues(alpha: 0.26);

            return Transform(
              alignment: Alignment.center,
              transform: transform,
              transformHitTests: false,
              child: GlassCard(
                useOwnLayer: true,
                settings: LiquidGlassSettings(
                  // TODO make singular origin for Glass Settings
                  chromaticAberration: 0.5,
                  thickness: 20,
                  ambientStrength: 0.5,
                  refractiveIndex: 1.33,
                  glassColor: glassColor,
                ),
                child: Container(
                  width: cardWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppElementSizes.cardRadius,
                    ),
                    child: Stack(
                      children: [
                        if (swipeFeedback != null)
                          _buildSwipeOverlay(
                            theme,
                            swipeFeedback,
                            cardWidth,
                            isFlipped,
                          ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppElementSizes.spacingMd,
                            ),
                            child: Center(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateY(isFlipped ? math.pi : 0.0),
                                child: Text(
                                  isFlipped
                                      ? widget.card.back
                                      : widget.card.front,
                                  style: const TextStyle(
                                    fontSize: AppTextSizes.small,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SwipeFeedback {
  final String label;
  final Color color;
  final Alignment gradientCenter;
  final bool labelAtTop;

  const _SwipeFeedback({
    required this.label,
    required this.color,
    required this.gradientCenter,
    required this.labelAtTop,
  });
}
