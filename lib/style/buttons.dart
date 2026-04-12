import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'liquid_glass_style.dart';
import 'theme.dart';

class GlassSquircleIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final bool isPrimary;
  final double size;

  const GlassSquircleIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isPrimary = false,
    this.size = AppElementSizes.buttonSquare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassButton.custom(
      onTap: onPressed ?? () {},
      enabled: onPressed != null,
      width: size,
      height: size,
      shape: const LiquidRoundedSuperellipse(
        borderRadius: AppElementSizes.cardRadius,
      ),
      settings: glassSettingsFor(context, isPrimary: isPrimary),
      child: IconTheme(
        data: IconThemeData(
          size: AppElementSizes.icon,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
        ),
        child: icon,
      ),
    );
  }
}

class GlassSquircleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isPrimary;
  final double height;
  final EdgeInsetsGeometry padding;

  const GlassSquircleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isPrimary = false,
    this.height = AppElementSizes.buttonHeight,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlassButton.custom(
      onTap: onPressed ?? () {},
      enabled: onPressed != null,
      height: height,
      shape: const LiquidRoundedSuperellipse(
        borderRadius: AppElementSizes.cardRadius,
      ),
      settings: glassSettingsFor(context, isPrimary: isPrimary),
      child: Padding(
        padding: padding,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: AppTextSizes.body,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.92),
          ),
          child: child,
        ),
      ),
    );
  }
}
