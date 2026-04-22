import 'package:flutter/material.dart';

import 'decorators.dart';
import 'theme.dart';

/// Glass-styled ElevatedButton that extends Material's ElevatedButton.
///
/// Supports [isPrimary] flag for primary color blend and hover glow effect.
class GlassElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isPrimary;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const GlassElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isPrimary = false,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(GlassEffects.radius);

    final buttonStyle = ButtonStyle(
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(padding),
      minimumSize: WidgetStateProperty.all<Size>(
        Size(width ?? 64, height ?? AppElementSizes.buttonHeight),
      ),
      maximumSize: width != null
          ? WidgetStateProperty.all<Size>(Size(width!, double.infinity))
          : null,
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: radius),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        final baseColor = getGlassSurfaceColor(
          colorScheme,
          isPrimary: isPrimary,
        );
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.surface.withValues(alpha: 0.15);
        }
        if (states.contains(WidgetState.pressed)) {
          return baseColor.withValues(alpha: 0.8);
        }
        return baseColor;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(
        getGlassTextColor(colorScheme, isPrimary: isPrimary),
      ),
      elevation: WidgetStateProperty.all<double>(0),
      shadowColor: WidgetStateProperty.all<Color>(Colors.transparent),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          final glowColor = colorScheme.primary.withValues(
            alpha: GlassEffects.glowIntensity,
          );
          return glowColor;
        }
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.primary.withValues(alpha: 0.08);
        }
        return null;
      }),
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: AppTextSizes.body,
          color: getGlassTextColor(colorScheme, isPrimary: isPrimary),
        ),
        child: child,
      ),
    );
  }
}

/// Glass-styled IconButton that extends Material's IconButton.
///
/// Supports [isPrimary] flag for primary color blend and hover glow.
class GlassIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final bool isPrimary;
  final double? size;
  final Color? color;
  final double? iconSize;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isPrimary = false,
    this.size,
    this.color,
    this.iconSize = AppElementSizes.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonSize = size ?? AppElementSizes.buttonSquare;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassEffects.radius),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(GlassEffects.radius),
          splashFactory: InkRipple.splashFactory,
          splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.05),
          child: IconTheme.merge(
            data: IconThemeData(
              size: iconSize,
              color:
                  color ??
                  getGlassTextColor(theme.colorScheme, isPrimary: isPrimary),
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}

/// Glass-styled squircle button using GlassElevatedButton with rounded rectangle shape.
///
/// This is a convenience widget that wraps [GlassElevatedButton] with a superellipse shape.
class GlassSquircleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isPrimary;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const GlassSquircleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isPrimary = false,
    this.width = 120,
    this.height = AppElementSizes.buttonHeight,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassElevatedButton(
      onPressed: onPressed,
      isPrimary: isPrimary,
      width: width,
      height: height,
      padding: padding,
      borderRadius: BorderRadius.circular(GlassEffects.radius),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: AppTextSizes.body,
          color: color ?? getGlassTextColor(colorScheme, isPrimary: isPrimary),
        ),
        child: child,
      ),
    );
  }
}

/// Glass-styled squircle icon button using GlassIconButton.
class GlassSquircleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final bool isPrimary;
  final double size;
  final Color? color;

  const GlassSquircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isPrimary = false,
    this.size = AppElementSizes.buttonSquare,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: getGlassSurfaceColor(Theme.of(context).colorScheme, isPrimary: isPrimary),
        borderRadius: BorderRadius.circular(GlassEffects.radius),
        border: Border.all(
          color: getGlassBorderColor(GlassEffects.strokeOpacity),
          width: GlassEffects.strokeWidth,
        ),
      ),
      child: GlassIconButton(
        onPressed: onPressed,
        isPrimary: isPrimary,
        size: size,
        color: color,
        icon: icon,
      ),
    );
  }
}
