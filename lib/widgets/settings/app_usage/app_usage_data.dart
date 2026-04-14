import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import '../../../data/models/app_usage.dart';
import '../../../data/db/isar_service.dart';
import '../../../style/theme.dart';

class AppUsageDataDialog extends StatefulWidget {
  final AppUsage appUsage;

  const AppUsageDataDialog({super.key, required this.appUsage});

  @override
  State<AppUsageDataDialog> createState() => _AppUsageDataDialogState();
}

class _AppUsageDataDialogState extends State<AppUsageDataDialog> {
  late TextEditingController _timeCtrl;
  String _selectedChallenge = 'Math';

  @override
  void initState() {
    super.initState();
    _timeCtrl = TextEditingController(text: widget.appUsage.maxDailyTimeLimit.toString());
  }

  @override
  void dispose() {
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final int limit = int.tryParse(_timeCtrl.text) ?? 15;
    widget.appUsage.maxDailyTimeLimit = limit;
    // Challenge type not explicitly in model yet, but logic is planned
    await idb.writeTxn(() async {
      await idb.appUsages.put(widget.appUsage);
    });
    if (mounted) Navigator.pop(context);
  }

  Future<void> _openChallengePicker() async {
    final types = ['Math', 'FlashCard', 'Puzzle'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppElementSizes.spacingLg),
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: types.map((type) {
                final isSelected = type == _selectedChallenge;
                return GlassListTile(
                  title: Text(
                    type,
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                      : null,
                  onTap: () => Navigator.pop(context, type),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _selectedChallenge = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: "${widget.appUsage.name} Usage Settings",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "Limit (mins):",
                  style: TextStyle(color: Colors.white, fontSize: AppTextSizes.body),
                ),
              ),
              const SizedBox(width: AppElementSizes.spacingSm),
              SizedBox(
                width: 120,
                child: GlassTextField(
                  controller: _timeCtrl,
                  placeholder: 'Minutes',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppElementSizes.spacingLg),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Challenge:",
                  style: TextStyle(color: Colors.white, fontSize: AppTextSizes.body),
                ),
              ),
              const SizedBox(width: AppElementSizes.spacingSm),
              SizedBox(
                width: 120,
                child: GlassPicker(
                  width: 120,
                  height: AppElementSizes.buttonHeight,
                  padding: const EdgeInsets.symmetric(horizontal: AppElementSizes.spacingSm),
                  value: _selectedChallenge,
                  textStyle: const TextStyle(fontSize: AppTextSizes.body, color: Colors.white),
                  placeholderStyle: TextStyle(
                    fontSize: AppTextSizes.body,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                  icon: const Icon(Icons.expand_more, size: AppElementSizes.icon, color: Colors.white),
                  onTap: _openChallengePicker,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: "Cancel",
          onPressed: () => Navigator.pop(context),
        ),
        GlassDialogAction(
          label: "Save",
          isPrimary: true,
          onPressed: _save,
        ),
      ],
    );
  }
}
