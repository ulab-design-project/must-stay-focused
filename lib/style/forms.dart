import 'package:flutter/material.dart';

import 'containers.dart';
import 'theme.dart';

/// Glass-styled InputDecoration.
///
/// Provides consistent glass styling for input fields.
class GlassInputDecoration extends InputDecoration {
  GlassInputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextStyle? hintStyle,
    BorderRadius? borderRadius,
    required ColorScheme colorScheme,
  }) : super(
         hintText: hintText,
         hintStyle:
             hintStyle ??
             TextStyle(
               color: colorScheme.onSurface.withValues(alpha: 0.6),
               fontSize: AppTextSizes.body,
             ),
         prefixIcon: prefixIcon,
         suffixIcon: suffixIcon,
         filled: true,
         fillColor: colorScheme.surface.withValues(alpha: GlassEffects.opacity),
         contentPadding: const EdgeInsets.symmetric(
           horizontal: AppElementSizes.spacingMd,
           vertical: AppElementSizes.spacingSm,
         ),
         border: OutlineInputBorder(
           borderRadius:
               borderRadius ?? BorderRadius.circular(GlassEffects.radius),
           borderSide: BorderSide(
             color: colorScheme.onSurface.withValues(
               alpha: GlassEffects.strokeOpacity,
             ),
             width: GlassEffects.strokeWidth,
           ),
         ),
         enabledBorder: OutlineInputBorder(
           borderRadius:
               borderRadius ?? BorderRadius.circular(GlassEffects.radius),
           borderSide: BorderSide(
             color: colorScheme.onSurface.withValues(
               alpha: GlassEffects.strokeOpacity,
             ),
             width: GlassEffects.strokeWidth,
           ),
         ),
         focusedBorder: OutlineInputBorder(
           borderRadius:
               borderRadius ?? BorderRadius.circular(GlassEffects.radius),
           borderSide: BorderSide(
             color: colorScheme.onSurface.withValues(
               alpha: GlassEffects.strokeOpacity * 1.5,
             ),
             width: GlassEffects.strokeWidth * 1.5,
           ),
         ),
         errorBorder: OutlineInputBorder(
           borderRadius:
               borderRadius ?? BorderRadius.circular(GlassEffects.radius),
           borderSide: BorderSide(
             color: colorScheme.error.withValues(alpha: 0.8),
             width: 1.5,
           ),
         ),
         focusedErrorBorder: OutlineInputBorder(
           borderRadius:
               borderRadius ?? BorderRadius.circular(GlassEffects.radius),
           borderSide: BorderSide(
             color: colorScheme.error.withValues(alpha: 0.9),
             width: 2.0,
           ),
         ),
       );
}

/// Glass-styled TextField widget.
class GlassTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;
  final TextStyle? textStyle;
  final TextStyle? placeholderStyle;

  const GlassTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.textStyle,
    this.placeholderStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      style:
          textStyle ??
          TextStyle(
            fontSize: AppTextSizes.body,
            color: theme.colorScheme.onSurface,
          ),
      decoration: GlassInputDecoration(
        hintText: placeholder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintStyle:
            placeholderStyle ??
            TextStyle(
              fontSize: AppTextSizes.body,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
        colorScheme: theme.colorScheme,
      ),
    );
  }
}

/// Glass-styled TextFormField widget.
class GlassTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;
  final TextStyle? textStyle;
  final TextStyle? placeholderStyle;

  const GlassTextFormField({
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.textStyle,
    this.placeholderStyle,
  });

  @override
  State<GlassTextFormField> createState() => _GlassTextFormFieldState();
}

class _GlassTextFormFieldState extends State<GlassTextFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.enabled,
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      style:
          widget.textStyle ??
          TextStyle(
            fontSize: AppTextSizes.body,
            color: theme.colorScheme.onSurface,
          ),
      decoration: GlassInputDecoration(
        hintText: widget.placeholder,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        hintStyle:
            widget.placeholderStyle ??
            TextStyle(
              fontSize: AppTextSizes.body,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
        colorScheme: theme.colorScheme,
      ),
    );
  }
}

/// Glass-styled dropdown button.
///
/// A dropdown with glass styling that opens a menu of options.
class GlassDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? placeholder;
  final double? width;
  final double? height;
  final bool isPrimary;

  const GlassDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.placeholder,
    this.width,
    this.height,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GlassCard(
      isPrimary: isPrimary,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      child: SizedBox(
        width: width,
        height: height ?? AppElementSizes.buttonHeight,
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<T>(
              value: value,
              onChanged: onChanged,
              items: items,
              hint: Text(
                placeholder ?? '',
                style: TextStyle(
                  fontSize: AppTextSizes.small,
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                ),
              ),
              icon: Icon(
                Icons.expand_more,
                size: AppElementSizes.icon,
                color: colorScheme.onSurface.withValues(alpha: 0.85),
              ),
              style: TextStyle(
                fontSize: AppTextSizes.small,
                color: colorScheme.onSurface,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
        ),
      ),
    );
  }
}
