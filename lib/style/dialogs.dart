import 'package:flutter/material.dart';
import 'package:must_stay_focused/style/buttons.dart';

import 'containers.dart';
import 'theme.dart';

/// Glass-styled dialog.
///
/// A dialog with glass surface styling and optional actions.
class GlassDialog extends StatelessWidget {
  final String title;
  final Widget? content;
  final List<Widget>? actions;
  final double? maxWidth;
  final double? maxHeight;

  const GlassDialog({
    super.key,
    required this.title,
    this.content,
    this.actions,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GlassEffects.radius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(AppElementSizes.spacingLg),
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppElementSizes.spacingMd),
          // Content
          if (content != null) ...[
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(AppElementSizes.spacingLg),
                child: SingleChildScrollView(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.87),
                      fontSize: AppTextSizes.body,
                    ),
                    child: content!,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppElementSizes.spacingMd),
          ],
          // Actions
          if (actions != null && actions!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!
                  .map(
                    (action) => Padding(
                      padding: const EdgeInsets.all(
                        AppElementSizes.spacingLg,
                      ),
                      child: action,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  /// Static method to show a glass dialog.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    List<Widget>? actions,
  }) {
    final theme = Theme.of(context);
    return showDialog<T>(
      context: context,
      builder: (context) => GlassDialog(
        title: title,
        content:
            content ??
            (message != null
                ? Text(
                    message,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  )
                : null),
        actions: actions,
      ),
    );
  }
}

/// Glass-styled dialog action button.
///
/// A convenience wrapper around TextButton with glass styling.
class GlassDialogAction extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback? onPressed;

  const GlassDialogAction({
    super.key,
    required this.label,
    this.isPrimary = false,
    this.isDestructive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final textColor = isDestructive
        ? theme.colorScheme.error
        : (isPrimary ? colorScheme.primary : colorScheme.onSurface);

    return GlassElevatedButton(
      onPressed: onPressed,
      isPrimary: isPrimary,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: AppTextSizes.body,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
