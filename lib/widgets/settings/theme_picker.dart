import 'package:flutter/material.dart';
import 'package:must_stay_focused/style/cards.dart';

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
              DropdownButton<String>(
                value: themeController.currentThemeKey,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    themeController.setTheme(newValue);
                  }
                },
                items: themes.keys.map<DropdownMenuItem<String>>((String value) {
                  final themeObj = themes[value]!;
                  final isLight = themeObj.brightness == Brightness.light;
                  final bgColor = themeObj.scaffoldBackgroundColor;
                  final primaryColor = themeObj.primaryColor;
    
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
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
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
