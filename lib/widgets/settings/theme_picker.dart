import 'package:flutter/material.dart';
import 'package:must_stay_focused/style/cards.dart';
import 'package:must_stay_focused/style/dropdown.dart';

import '../../style/theme.dart';

class ThemePicker extends StatefulWidget {
  const ThemePicker({super.key});

  @override
  State<ThemePicker> createState() => _ThemePickerState();
}

class _ThemePickerState extends State<ThemePicker> {
  @override
  Widget build(BuildContext context) {
    return GlassListTile(
      title: const Text('Theme'),
      trailing: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlassDropdown<String>(
                value: themeController.currentThemeKey,
                items: themes.keys.toList(),
                itemBuilder: (value) => value,
                selectedItemBuilder: (value) {
                  final themeObj = themes[value]!;
                  final isLight = themeObj.brightness == Brightness.light;
                  final primaryColor = themeObj.primaryColor;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLight ? Icons.wb_sunny : Icons.nightlight_round,
                        color: primaryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(value),
                    ],
                  );
                },
                dropdownItemBuilder: (value, isSelected) {
                  final themeObj = themes[value]!;
                  final isLight = themeObj.brightness == Brightness.light;
                  final bgColor = themeObj.scaffoldBackgroundColor;
                  final primaryColor = themeObj.primaryColor;

                  return Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isLight ? Icons.wb_sunny : Icons.nightlight_round,
                            color: primaryColor,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    ],
                  );
                },
                onChanged: (newValue) {
                  themeController.setTheme(newValue);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
