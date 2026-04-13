import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool isFormField;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final InputBorder? border;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;

  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.isFormField = false,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.border,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final op = themeController.glassOpacity;
    final blur = themeController.glassBlur;

    Color bgColor = _isFocused
        ? theme.colorScheme.surface.withValues(alpha: op + 0.1)
        : theme.colorScheme.surface.withValues(alpha: op);

    InputDecoration inputDecoration = InputDecoration(
      hintText: widget.hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      border: widget.border ?? InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
    );

    Widget textField = widget.isFormField
        ? TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            validator: widget.validator,
            onChanged: widget.onChanged,
            style: theme.textTheme.bodyMedium,
            decoration: inputDecoration,
            onTap: () => setState(() => _isFocused = true),
            onEditingComplete: () => setState(() => _isFocused = false),
            maxLines: widget.maxLines,
          )
        : TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            onChanged: widget.onChanged,
            style: theme.textTheme.bodyMedium,
            decoration: inputDecoration,
            onTap: () => setState(() => _isFocused = true),
            onEditingComplete: () => setState(() => _isFocused = false),
            maxLines: widget.maxLines,
          );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          blendMode: BlendMode.src,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isFocused
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: textField,
            ),
          ),
        ),
      ),
    );
  }
}
