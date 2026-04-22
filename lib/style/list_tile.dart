import 'package:flutter/material.dart';

import 'decorators.dart';
import 'theme.dart';

/// Glass-styled ListTile.
///
/// Extends the standard ListTile with glass surface styling and optional trailing actions.
class GlassListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isLast;
  final bool isThreeLine;
  final bool dense;
  final Color? titleColor;
  final Color? subtitleColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GlassListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isLast = false,
    this.isThreeLine = false,
    this.dense = false,
    this.titleColor,
    this.subtitleColor,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build the inner ListTile
    Widget tile = ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      isThreeLine: isThreeLine,
      dense: dense,
      onTap: onTap,
      onLongPress: onLongPress,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppElementSizes.spacingMd,
        vertical: AppElementSizes.spacingXs,
      ),
    );

    // Apply text colors via DefaultTextStyle if provided
    if (titleColor != null || subtitleColor != null) {
      tile = DefaultTextStyle(
        style: theme.textTheme.bodyMedium!.copyWith(
          color: titleColor ?? getGlassTextColor(colorScheme),
        ),
        child: tile,
      );
    }

    if (subtitleColor != null) {
      // For subtitle color, we'd need to wrap the subtitle widget directly
      // This is a simplified approach
    }

    // Wrap in glass container for background
    return Container(
      decoration: BoxDecoration(
        color: getGlassSurfaceColor(colorScheme),
        borderRadius: BorderRadius.circular(GlassEffects.radius),
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: getGlassBorderColor(GlassEffects.strokeOpacity * 0.5),
                  width: 0.5,
                ),
              ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GlassEffects.radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppElementSizes.spacingMd,
            vertical: AppElementSizes.spacingXs,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppElementSizes.spacingMd),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      DefaultTextStyle(
                        style: TextStyle(
                          color: titleColor ?? getGlassTextColor(colorScheme),
                          fontSize: AppTextSizes.body,
                        ),
                        child: title!,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppElementSizes.spacingXs),
                      DefaultTextStyle(
                        style: TextStyle(
                          color:
                              subtitleColor ??
                              colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: AppTextSizes.small,
                        ),
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppElementSizes.spacingSm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
