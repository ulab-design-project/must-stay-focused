import 'dart:math';

import 'package:flutter/material.dart';

import '../../style/buttons.dart';
import '../../style/progress_indicator.dart';
import '../../style/theme.dart';

class PairMatchingChallengeWidget extends StatefulWidget {
  final VoidCallback onSolved;

  const PairMatchingChallengeWidget({super.key, required this.onSolved});

  @override
  State<PairMatchingChallengeWidget> createState() =>
      _PairMatchingChallengeWidgetState();
}

class _PairMatchingChallengeWidgetState
    extends State<PairMatchingChallengeWidget> {
  static const int _gridSize = 4;
  static const int _pairCount = 8;

  static const List<IconData> _iconPool = [
    Icons.home,
    Icons.favorite,
    Icons.star,
    Icons.work,
    Icons.book,
    Icons.music_note,
    Icons.camera_alt,
    Icons.flight,
    Icons.coffee,
    Icons.pets,
    Icons.sports_soccer,
    Icons.build,
    Icons.lightbulb,
    Icons.phone_android,
    Icons.map,
    Icons.wb_sunny,
    Icons.nightlight_round,
    Icons.park,
    Icons.restaurant,
    Icons.movie,
  ];

  final Random _random = Random();

  late List<_PairTile> _tiles;
  final List<int> _openTileIndexes = [];
  int _matchedPairs = 0;
  bool _isResolvingPair = false;
  bool _solveNotified = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    final iconChoices = [..._iconPool]..shuffle(_random);
    final selectedIcons = iconChoices.take(_pairCount).toList(growable: false);

    final tiles = <_PairTile>[];
    int tileId = 0;

    for (int pairId = 0; pairId < selectedIcons.length; pairId++) {
      final icon = selectedIcons[pairId];
      tiles.add(_PairTile(id: tileId++, pairId: pairId, icon: icon));
      tiles.add(_PairTile(id: tileId++, pairId: pairId, icon: icon));
    }

    tiles.shuffle(_random);

    _tiles = tiles;
    _openTileIndexes.clear();
    _matchedPairs = 0;
    _isResolvingPair = false;
    _solveNotified = false;
  }

  double get _progressValue => _matchedPairs / _pairCount;

  void _onTileTap(int index) {
    if (_isResolvingPair) {
      return;
    }

    final tile = _tiles[index];
    if (tile.isMatched || tile.isFaceUp) {
      return;
    }

    setState(() {
      tile.isFaceUp = true;
      _openTileIndexes.add(index);
    });

    if (_openTileIndexes.length < 2) {
      return;
    }

    _resolveOpenPair();
  }

  Future<void> _resolveOpenPair() async {
    if (_openTileIndexes.length != 2) {
      return;
    }

    _isResolvingPair = true;

    final firstIndex = _openTileIndexes[0];
    final secondIndex = _openTileIndexes[1];

    final firstTile = _tiles[firstIndex];
    final secondTile = _tiles[secondIndex];

    if (firstTile.pairId == secondTile.pairId) {
      setState(() {
        firstTile.isMatched = true;
        secondTile.isMatched = true;
        _openTileIndexes.clear();
        _matchedPairs += 1;
      });

      if (_matchedPairs == _pairCount && !_solveNotified) {
        _solveNotified = true;
        widget.onSolved();
      }

      _isResolvingPair = false;
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 550));

    if (!mounted) {
      return;
    }

    setState(() {
      firstTile.isFaceUp = false;
      secondTile.isFaceUp = false;
      _openTileIndexes.clear();
    });

    _isResolvingPair = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Match all icon pairs',
          style: TextStyle(color: onSurface, fontSize: AppTextSizes.body),
        ),
        const SizedBox(height: AppElementSizes.spacingSm),
        GlassProgressIndicator.linear(
          color: theme.colorScheme.primary,
          value: _progressValue,
          height: 8,
          minWidth: 260,
        ),
        const SizedBox(height: AppElementSizes.spacingSm),
        Text(
          '${_matchedPairs * 2} / ${_gridSize * _gridSize} matched',
          style: TextStyle(color: onSurface, fontSize: AppTextSizes.small),
        ),
        const SizedBox(height: AppElementSizes.spacingMd),
        SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridSize,
              crossAxisSpacing: AppElementSizes.spacingSm,
              mainAxisSpacing: AppElementSizes.spacingSm,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final tile = _tiles[index];
              final showIcon = tile.isFaceUp || tile.isMatched;
              final isEnabled = !tile.isMatched && !_isResolvingPair;

              return Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) {
                    return RotationYTransition(turns: animation, child: child);
                  },
                  child: GlassSquircleIconButton(
                    key: ValueKey<String>(
                      '${tile.id}-${showIcon ? 'up' : 'down'}-${tile.isMatched}',
                    ),
                    size: 64,
                    onPressed: isEnabled ? () => _onTileTap(index) : null,
                    icon: Icon(showIcon ? tile.icon : Icons.help_outline),
                    color: onSurface,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppElementSizes.spacingSm),
        Text(
          _matchedPairs == _pairCount
              ? 'Progress full. You can press Submit now.'
              : 'Find each pair by tapping two tiles.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.85),
            fontSize: AppTextSizes.small,
          ),
        ),
      ],
    );
  }
}

class _PairTile {
  final int id;
  final int pairId;
  final IconData icon;
  bool isFaceUp = false;
  bool isMatched = false;

  _PairTile({required this.id, required this.pairId, required this.icon});
}

class RotationYTransition extends AnimatedWidget {
  final Widget child;

  const RotationYTransition({
    super.key,
    required Animation<double> turns,
    required this.child,
  }) : super(listenable: turns);

  Animation<double> get turns => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final value = turns.value;
    final angle = value * pi;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(angle),
      alignment: Alignment.center,
      child: child,
    );
  }
}
