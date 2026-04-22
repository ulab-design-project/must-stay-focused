import 'package:flutter/material.dart';

import 'decorators.dart';
import 'theme.dart';

/// Glass-styled Chip widget.
///
/// A chip with glass surface styling and optional selection state.
class GlassChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isPrimary;
  final VoidCallback? onTap;
  final Icon? leading;
  final Icon? trailing;
  final TextStyle? labelStyle;
  final Color? iconColor;

  const GlassChip({
    super.key,
    required this.label,
    this.selected = false,
    this.isPrimary = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.labelStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = selected
        ? colorScheme.primary.withValues(alpha: GlassEffects.opacity * 0.6)
        : getGlassSurfaceColor(colorScheme, isPrimary: isPrimary);

    // Determine text color: use labelStyle's color if provided, else default
    final defaultTextColor = selected
        ? colorScheme.onPrimary
        : getGlassTextColor(colorScheme, isPrimary: isPrimary);
    final effectiveTextStyle =
        labelStyle ??
        TextStyle(
          fontSize: AppTextSizes.compact,
          color: defaultTextColor,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        );

    final iconColorEffective = iconColor ?? effectiveTextStyle.color;

    final borderColor = selected
        ? Colors.transparent
        : getGlassBorderColor(GlassEffects.strokeOpacity * 0.6);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor,
          width: selected ? 0 : GlassEffects.strokeWidth * 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppElementSizes.spacingSm,
              vertical: AppElementSizes.spacingXs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(size: 16, color: iconColorEffective),
                    child: leading!,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(label, style: effectiveTextStyle),
                if (trailing != null) ...[
                  const SizedBox(width: 4),
                  IconTheme.merge(
                    data: IconThemeData(size: 16, color: iconColorEffective),
                    child: trailing!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
