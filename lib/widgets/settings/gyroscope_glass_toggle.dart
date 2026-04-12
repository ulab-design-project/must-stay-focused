import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../style/theme.dart';

class GyroscopeGlassToggle extends StatelessWidget {
  const GyroscopeGlassToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final enabled = themeController.isGyroscopeEnabled;
        final theme = Theme.of(context);

        return GlassListTile(
          title: Text(
              'Gyroscope Light Motion',
              style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          subtitle: Text('Enable tilt-reactive glass highlights',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ),
          trailing: GlassSwitch(
            value: enabled,
            activeColor: theme.colorScheme.primary,
            inactiveColor: theme.colorScheme.primary.withValues(alpha: 0.25),
            onChanged: (value) async {
              try {
                await themeController.setGyroscopeEnabled(value);
              } catch (e, stackTrace) {
                debugPrint('GyroscopeGlassToggle onChanged error: $e');
                debugPrintStack(stackTrace: stackTrace);
              }
            },
          ),
          isLast: true,
        );
      },
    );
  }
}
