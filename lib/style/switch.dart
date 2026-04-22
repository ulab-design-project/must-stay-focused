import 'package:flutter/material.dart';

import 'decorators.dart';
import 'theme.dart';

/// Glass-styled Switch widget.
///
/// Extends Material's Switch with glass-morphism styling. Provides a
/// semi-transparent track with subtle border and primary color glow on hover.
class GlassSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool isPrimary;

  const GlassSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.isPrimary = false,
  });

  @override
  State<GlassSwitch> createState() => _GlassSwitchState();
}

class _GlassSwitchState extends State<GlassSwitch> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeTrack = widget.activeColor ?? colorScheme.primary;
    final inactiveTrack = widget.inactiveColor ?? colorScheme.surface;

    final activeTrackColor = activeTrack.withValues(
      alpha: GlassEffects.opacity,
    );
    final inactiveTrackColor = inactiveTrack.withValues(
      alpha: GlassEffects.opacity,
    );
    final borderColor = getGlassBorderColor(GlassEffects.strokeOpacity);
    final thumbColor = widget.value ? activeTrack : colorScheme.surface;

    final glow = _hovered && widget.value
        ? [
            BoxShadow(
              color: colorScheme.primary.withValues(
                alpha: GlassEffects.glowIntensity,
              ),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ]
        : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onChanged != null
            ? () => widget.onChanged!(!widget.value)
            : null,
        child: SizedBox(
          width: 40,
          height: 24,
          child: Stack(
            children: [
              // Track
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.value ? activeTrackColor : inactiveTrackColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: GlassEffects.strokeWidth,
                  ),
                  boxShadow: glow,
                ),
              ),
              // Thumb
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: widget.value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: thumbColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: GlassEffects.strokeWidth,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
