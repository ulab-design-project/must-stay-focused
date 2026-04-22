import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:isar/isar.dart';

import '../data/db/isar_service.dart';
import '../data/db/quotes.dart';
import '../data/models/app_usage.dart';
import '../data/models/user_settings.dart';
import '../services/app_interception_service.dart';
import '../services/appUsageMonitor/android_app_usage.dart';
import '../style/background.dart';
import '../style/buttons.dart';
import '../style/containers.dart';
import '../style/list_tile.dart';
import '../style/picker.dart';
import '../style/theme.dart';
import '../widgets/challenge/flashcard_challenge.dart';
import '../widgets/challenge/math_challenge.dart';
import '../widgets/challenge/pair_matching_challenge.dart';

class ChallengePage extends StatefulWidget {
  final AppUsage appUsage;
  final Uint8List? appIconBytes;
  final DifficultySettings difficulty;

  const ChallengePage({
    super.key,
    required this.appUsage,
    this.appIconBytes,
    this.difficulty = DifficultySettings.easy,
  });

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  static const List<String> _challengeTypes = [
    'Math',
    'Flashcard',
    'Pair Matching',
  ];

  final Random _random = Random();

  late String _quote;
  late String _selectedChallengeType;
  bool _isSolved = false;
  bool _isSubmitting = false;
  int _defaultOvertimeLimit = 15;
  Uint8List? _iconBytes;

  @override
  void initState() {
    super.initState();
    _quote = quotes[_random.nextInt(quotes.length)];
    _selectedChallengeType = _normalizeChallengeType(
      widget.appUsage.challengeType,
    );
    _iconBytes = widget.appIconBytes;
    _loadDefaults();
  }

  String _normalizeChallengeType(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';

    switch (normalized) {
      case 'math':
        return 'Math';
      case 'flash card':
      case 'flashcard':
        return 'Flashcard';
      case 'pair matching':
      case 'pairmatching':
      case 'puzzle':
        return 'Pair Matching';
      default:
        return 'Math';
    }
  }

  Future<void> _loadDefaults() async {
    try {
      final settings = await idb.userSettings.get(1);
      final fallbackChallenge = _normalizeChallengeType(
        settings?.preferredChallengeType,
      );

      if (!_challengeTypes.contains(_selectedChallengeType)) {
        _selectedChallengeType = fallbackChallenge;
      }

      _defaultOvertimeLimit = settings?.defaultOvertimeLimitMinutes ?? 15;

      if (_iconBytes == null) {
        final appIcons = await AndroidAppUsageMonitor().getTrackedAppIcons({
          widget.appUsage.appId,
        });
        _iconBytes = appIcons[widget.appUsage.appId];
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      debugPrint('ChallengePage _loadDefaults error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _onChallengeSolved() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isSolved = true;
    });
  }

  Future<void> _openChallengePicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingLg),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _challengeTypes.map((type) {
                final isSelected = type == _selectedChallengeType;
                return GlassListTile(
                  title: Text(
                    type,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, type),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedChallengeType = selected;
      _isSolved = false;
    });
  }

  Future<void> _submitChallenge() async {
    if (_isSubmitting || !_isSolved) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final latestApp = await idb.appUsages
          .where()
          .appIdEqualTo(widget.appUsage.appId)
          .findFirst();
      if (latestApp == null) {
        throw Exception('Tracked app no longer exists in local database.');
      }

      final int overtimeToAdd = max(_defaultOvertimeLimit, 0);
      if (overtimeToAdd <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Overtime limit is blocked in settings.'),
            ),
          );
          Navigator.pop(context, false);
        }
        return;
      }

      await idb.writeTxn(() async {
        latestApp.challengeType = _selectedChallengeType;
        latestApp.overTimeLimitToday = overtimeToAdd;
        await idb.appUsages.put(latestApp);
      });

      await AppInterceptionService().setAppBypassMinutes(
        appId: latestApp.appId,
        minutes: overtimeToAdd,
      );

      await InstalledApps.startApp(latestApp.appId);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      debugPrint('ChallengePage _submitChallenge error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to continue to app. Try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildChallengeWidget() {
    switch (_selectedChallengeType) {
      case 'Math':
        return MathChallengeWidget(
          onSuccess: _onChallengeSolved,
          difficulty: widget.difficulty,
        );
      case 'Flashcard':
        return FlashcardChallengeWidget(onSolved: _onChallengeSolved);
      case 'Pair Matching':
        return PairMatchingChallengeWidget(onSolved: _onChallengeSolved);
      default:
        return MathChallengeWidget(
          onSuccess: _onChallengeSolved,
          difficulty: widget.difficulty,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return BackgroundDrop(
      scaffold: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Continue to ${widget.appUsage.name}',
            style: TextStyle(color: onSurface),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppElementSizes.spacingLg),
              child: SizedBox(
                width: AppElementSizes.buttonSquare,
                height: AppElementSizes.buttonSquare,
                child: _iconBytes != null
                    ? Image.memory(
                        _iconBytes!,
                        width: AppElementSizes.icon,
                        height: AppElementSizes.icon,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.low,
                      )
                    : Icon(
                        Icons.android,
                        color: onSurface,
                        size: AppElementSizes.icon,
                      ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppElementSizes.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Challenge',
                    style: TextStyle(
                      color: onSurface,
                      fontSize: AppTextSizes.title,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppElementSizes.spacingMd),
                  GlassPicker(
                    width: 160,
                    height: AppElementSizes.buttonHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppElementSizes.spacingSm,
                    ),
                    value: _selectedChallengeType,
                    textStyle: TextStyle(
                      fontSize: AppTextSizes.body,
                      color: onSurface,
                    ),
                    placeholderStyle: TextStyle(
                      fontSize: AppTextSizes.body,
                      color: onSurface.withValues(alpha: 0.65),
                    ),
                    icon: Icon(
                      Icons.expand_more,
                      size: AppElementSizes.icon,
                      color: onSurface,
                    ),
                    onTap: _openChallengePicker,
                  ),
                ],
              ),
              const SizedBox(height: AppElementSizes.spacingLg),
              _buildChallengeWidget(),
              const SizedBox(height: AppElementSizes.spacingLg),
              Text(
                _quote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.92),
                  fontSize: AppTextSizes.body,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppElementSizes.spacingLg),
              GlassSquircleButton(
                width: 200,
                isPrimary: true,
                onPressed: _isSolved && !_isSubmitting
                    ? _submitChallenge
                    : null,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : _isSolved
                    ? const Text('Continue to App')
                    : const Text('Challenge Incomplete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
