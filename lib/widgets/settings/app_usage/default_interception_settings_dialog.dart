import 'package:flutter/material.dart';

import '../../../data/db/isar_service.dart';
import '../../../data/models/user_settings.dart';
import '../../../services/app_interception_service.dart';
import '../../../style/containers.dart';
import '../../../style/dialogs.dart';
import '../../../style/forms.dart';
import '../../../style/list_tile.dart';
import '../../../style/picker.dart';
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
  final TextEditingController _warningSecondsCtrl = TextEditingController();
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
    _warningSecondsCtrl.dispose();
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
        _warningSecondsCtrl.text =
            (settings?.warningSecondsBeforeIntercept ?? 10).toString();
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
        _warningSecondsCtrl.text = '10';
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
                return Padding(
                  padding: const EdgeInsets.all(AppElementSizes.spacingSm),
                  child: GlassListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, option),
                  ),
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

      final warningParsed = int.tryParse(_warningSecondsCtrl.text.trim()) ?? 10;
      final warningSeconds = warningParsed.clamp(0, 300);

      await idb.writeTxn(() async {
        final settings =
            await idb.userSettings.get(1) ?? (UserSettings()..id = 1);
        settings.defaultOvertimeLimitMinutes = overtime;
        settings.preferredChallengeType = _selectedChallengeType;
        settings.warningSecondsBeforeIntercept = warningSeconds;
        await idb.userSettings.put(settings);
      });

      // Sync settings to native
      await AppInterceptionService().syncSettings();

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
    final theme = Theme.of(context);
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
                    color: theme.colorScheme.onSurface,
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
                      ),
                    ),
                    const SizedBox(width: AppElementSizes.spacingSm),
                    Text(
                      'Minutes for Challenge',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: AppTextSizes.small,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppElementSizes.spacingLg),
                Text(
                  'Challenge Type',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
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
                    textStyle: TextStyle(
                      fontSize: AppTextSizes.body,
                      color: theme.colorScheme.onSurface,
                    ),
                    placeholderStyle: TextStyle(
                      fontSize: AppTextSizes.body,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                    ),
                    icon: Icon(
                      Icons.expand_more,
                      size: AppElementSizes.icon,
                      color: theme.colorScheme.onSurface,
                    ),
                    onTap: _openChallengePicker,
                  ),
                ),
                const SizedBox(height: AppElementSizes.spacingLg),
                Text(
                  'Warning Before Block',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: AppTextSizes.body,
                  ),
                ),
                const SizedBox(height: AppElementSizes.spacingSm),
                Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: GlassTextField(
                        controller: _warningSecondsCtrl,
                        placeholder: 'Sec',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppElementSizes.spacingSm),
                    Text(
                      'Seconds before block warning',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: AppTextSizes.small,
                      ),
                    ),
                  ],
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
