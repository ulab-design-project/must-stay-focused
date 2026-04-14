import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../data/db/isar_service.dart';
import '../../../data/models/user_settings.dart';
import '../../../style/theme.dart';

class DefaultInterceptionSettingsDialog extends StatefulWidget {
  const DefaultInterceptionSettingsDialog({super.key});

  @override
  State<DefaultInterceptionSettingsDialog> createState() =>
      _DefaultInterceptionSettingsDialogState();
}

class _DefaultInterceptionSettingsDialogState
    extends State<DefaultInterceptionSettingsDialog> {
  final TextEditingController _overtimeCtrl = TextEditingController();
  String _selectedChallengeType = 'Math';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _overtimeCtrl.dispose();
    super.dispose();
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

  Future<void> _loadSettings() async {
    try {
      final settings = await idb.userSettings.get(1);
      final overtime = settings?.defaultOvertimeLimitMinutes ?? 15;

      if (!mounted) {
        return;
      }

      setState(() {
        _overtimeCtrl.text = overtime.toString();
        _selectedChallengeType = _normalizeChallengeType(
          settings?.preferredChallengeType,
        );
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('DefaultInterceptionSettingsDialog load error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      setState(() {
        _overtimeCtrl.text = '15';
        _selectedChallengeType = 'Math';
        _isLoading = false;
      });
    }
  }

  Future<void> _openChallengePicker() async {
    const options = ['Math', 'Flashcard', 'Pair Matching'];

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingLg),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options.map((option) {
                final isSelected = option == _selectedChallengeType;
                return GlassListTile(
                  title: Text(
                    option,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.white)
                      : null,
                  onTap: () => Navigator.pop(context, option),
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
    });
  }

  Future<void> _save() async {
    try {
      final parsed = int.tryParse(_overtimeCtrl.text.trim()) ?? 15;
      final overtime = parsed.clamp(0, 600);

      await idb.writeTxn(() async {
        final settings =
            await idb.userSettings.get(1) ?? (UserSettings()..id = 1);
        settings.defaultOvertimeLimitMinutes = overtime;
        settings.preferredChallengeType = _selectedChallengeType;
        await idb.userSettings.put(settings);
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      debugPrint('DefaultInterceptionSettingsDialog save error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: 'Default App Settings',
      content: _isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppElementSizes.spacingLg,
              ),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Overtime Limit (0 to block)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTextSizes.body,
                  ),
                ),
                const SizedBox(height: AppElementSizes.spacingSm),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: GlassTextField(
                        controller: _overtimeCtrl,
                        placeholder: 'Minutes',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: AppElementSizes.spacingSm),
                    Text(
                      'Minutes for Challenge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTextSizes.small,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppElementSizes.spacingLg),
                Text(
                  'Challenge Type',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppTextSizes.body,
                  ),
                ),
                const SizedBox(height: AppElementSizes.spacingSm),
                SizedBox(
                  width: 170,
                  child: GlassPicker(
                    width: 170,
                    height: AppElementSizes.buttonHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppElementSizes.spacingSm,
                    ),
                    value: _selectedChallengeType,
                    textStyle: const TextStyle(
                      fontSize: AppTextSizes.body,
                      color: Colors.white,
                    ),
                    placeholderStyle: TextStyle(
                      fontSize: AppTextSizes.body,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                    icon: const Icon(
                      Icons.expand_more,
                      size: AppElementSizes.icon,
                      color: Colors.white,
                    ),
                    onTap: _openChallengePicker,
                  ),
                ),
              ],
            ),
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        GlassDialogAction(label: 'Save', isPrimary: true, onPressed: _save),
      ],
    );
  }
}
