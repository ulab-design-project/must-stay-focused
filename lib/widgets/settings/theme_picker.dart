import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../style/theme.dart';
import 'gyroscope_glass_toggle.dart';

class ThemePicker extends StatefulWidget {
  const ThemePicker({super.key});

  @override
  State<ThemePicker> createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  Future<void> _openThemePicker() async {
    try {
      final selected = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          final entries = themes.entries.toList();
          return Padding(
            padding: const EdgeInsets.all(AppElementSizes.spacingLg),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...entries.map((entry) {
                    final isSelected =
                        entry.key == themeController.currentThemeKey;
                    final isLightMode =
                        entry.value.brightness == Brightness.light;
                    return GlassListTile(
                      leading: Icon(
                        isLightMode ? Icons.wb_sunny : Icons.nightlight_round,
                        color: entry.value.primaryColor,
                      ),
                      title: Text(
                        entry.key,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.of(context).pop(entry.key),
                      isLast: entry == entries.last,
                    );
                  }),
                ],
              ),
            ),
          );
        },
      );

      if (selected != null && mounted) {
        await themeController.setTheme(selected);
      }
    } catch (e, stackTrace) {
      debugPrint('ThemePicker _openThemePicker error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      padding: EdgeInsets.zero,
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          final selectedTheme = themeController.currentThemeKey;
          final selectedThemeData =
              themes[selectedTheme] ?? themes.values.first;
          final isLight = selectedThemeData.brightness == Brightness.light;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassListTile(
                title: Text(
                  'Theme',
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                subtitle: Text(
                  selectedTheme,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  ),
                ),
                leading: Icon(
                  isLight ? Icons.wb_sunny : Icons.nightlight_round,
                  color: selectedThemeData.primaryColor,
                ),
                trailing: GlassPicker(
                  width: 96,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  value: selectedTheme,
                  textStyle: TextStyle(
                    fontSize: AppTextSizes.compact,
                    color: theme.colorScheme.onSurface,
                  ),
                  placeholderStyle: TextStyle(
                    fontSize: AppTextSizes.compact,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                  icon: Icon(
                    Icons.expand_more,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                  onTap: _openThemePicker,
                ),
                isLast: false,
              ),
              const GyroscopeGlassToggle(),
            ],
          );
        },
      ),
    );
  }
}
