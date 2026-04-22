import 'package:flutter/material.dart';

import 'containers.dart';
import 'list_tile.dart';
import 'dialogs.dart';
import 'theme.dart';

/// Glass-styled picker/dropdown trigger.
///
/// Displays a glass card that opens a dialog with options when tapped.
/// This replaces the GlassPicker from liquid_glass_widgets.
class GlassPicker extends StatelessWidget {
  final String value;
  final String? placeholder;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;
  final TextStyle? placeholderStyle;
  final Widget? icon;
  final VoidCallback? onTap;

  const GlassPicker({
    super.key,
    required this.value,
    this.placeholder,
    this.width = 120,
    this.height = AppElementSizes.buttonHeight,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.textStyle,
    this.placeholderStyle,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayText = placeholder != null && value.isEmpty
        ? placeholder!
        : value;
    final style =
        textStyle ??
        TextStyle(fontSize: AppTextSizes.small, color: colorScheme.onSurface);
    final placeholderStyl =
        placeholderStyle ??
        TextStyle(
          fontSize: AppTextSizes.small,
          color: colorScheme.onSurface.withValues(alpha: 0.65),
        );

    return GlassCard(
      isPrimary: false,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: width,
        height: height,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GlassEffects.radius),
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: value.isEmpty ? placeholderStyl : style,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null) ...[const SizedBox(width: 4), icon!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper to show a simple selection dialog with glass styling.
Future<T?> showGlassSelectionDialog<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required String Function(T) labelFor,
  T? selectedValue,
  Widget Function(T)? trailingFor,
}) {
  return showDialog<T>(
    context: context,
    builder: (context) => GlassDialog(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .asMap()
            .entries
            .map(
              (entry) => GlassListTile(
                isLast: entry.key == options.length - 1,
                title: Text(
                  labelFor(entry.value),
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: trailingFor != null
                    ? trailingFor(entry.value)
                    : (selectedValue == entry.value
                          ? const Icon(Icons.check, color: Colors.white)
                          : null),
                onTap: () => Navigator.pop(context, entry.value),
              ),
            )
            .toList(),
      ),
      actions: [
        GlassDialogAction(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
