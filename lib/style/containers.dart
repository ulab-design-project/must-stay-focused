import 'package:flutter/material.dart';

import 'decorators.dart';
import 'theme.dart';

/// A glass-styled Card widget.
///
/// Extends Material's Card with a semi-transparent background,
/// subtle border, and optional hover glow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool isPrimary;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppElementSizes.spacingMd),
    this.margin = const EdgeInsets.symmetric(
      horizontal: AppElementSizes.spacingMd,
      vertical: AppElementSizes.spacingXs,
    ),
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget card = Container(
      decoration: BoxDecoration(
        color: getGlassSurfaceColor(colorScheme, isPrimary: isPrimary),
        borderRadius: BorderRadius.circular(GlassEffects.radius),
        border: Border.all(
          color: getGlassBorderColor(GlassEffects.strokeOpacity),
          width: GlassEffects.strokeWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(GlassEffects.radius),
            child: child,
          ),
        ),
      ),
    );

    return card;
  }
}

/// Simple glass container without Card semantics.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool isPrimary;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppElementSizes.spacingMd),
    this.margin = EdgeInsets.zero,
    this.isPrimary = false,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(GlassEffects.radius);

    Widget container = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: getGlassSurfaceColor(colorScheme, isPrimary: isPrimary),
        borderRadius: radius,
        border: Border.all(
          color: getGlassBorderColor(GlassEffects.strokeOpacity),
          width: GlassEffects.strokeWidth,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap != null) {
      container = Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: radius, child: container),
      );
    }

    return container;
  }
}
