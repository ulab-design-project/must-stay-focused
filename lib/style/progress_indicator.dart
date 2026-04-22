import 'package:flutter/material.dart';

import 'decorators.dart';
import 'theme.dart';

/// Glass-styled linear progress indicator.
///
/// Provides a semi-transparent track with glass border and a filled portion
/// representing progress value. No backdrop blur, with subtle stroke.
class GlassProgressIndicator extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color color;
  final double height;
  final double? minWidth;
  final bool isPrimary;

  const GlassProgressIndicator.linear({
    super.key,
    required this.value,
    required this.color,
    this.height = 8.0,
    this.minWidth,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    // Track background: semi-transparent white (glass surface)
    final trackColor = Colors.white.withValues(
      alpha: GlassEffects.opacity * 0.5,
    );
    // Border stroke
    final borderColor = getGlassBorderColor(GlassEffects.strokeOpacity);
    // Fill color
    final fillColor = color;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth ?? 0, minHeight: height),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(GlassEffects.radius),
          border: Border.all(
            color: borderColor,
            width: GlassEffects.strokeWidth,
          ),
        ),
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              color: fillColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(GlassEffects.radius - 1),
            ),
          ),
        ),
      ),
    );
  }
}
