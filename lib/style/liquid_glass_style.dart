import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

LiquidGlassSettings glassSettingsFor(
  BuildContext context, {
  bool isPrimary = false,
  double colorRatio = 0.4,
}) {
  final ratio = colorRatio.clamp(0.0, 1.0);
  final theme = Theme.of(context);
  final base =
      GlassThemeData.of(context).settingsFor(context) ??
      const LiquidGlassSettings(
        
      );

  if (!isPrimary) {
    return base;
  }

  final tintedPrimary = theme.colorScheme.primary.withValues(alpha: 0.5);
  return base.copyWith(
    glassColor:
        Color.lerp(base.glassColor, tintedPrimary, ratio) ?? tintedPrimary,
  );
}
