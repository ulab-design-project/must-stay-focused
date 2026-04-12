import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

class GlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool isFormField;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;

  const GlassTextField({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.isFormField = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final op = themeController.glassOpacity;
    final blur = themeController.glassBlur;

    Color bgColor = _isFocused
        ? theme.colorScheme.surface.withValues(alpha: op + 0.1)
        : theme.colorScheme.surface.withValues(alpha: op);

    Widget input = TextField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        errorText: _errorText,
        counterText: '',
      ),
      onTap: () => setState(() => _isFocused = true),
      onEditingComplete: () => setState(() => _isFocused = false),
      onSubmitted: (_) => setState(() => _isFocused = false),
    );

    if (widget.isFormField) {
      input = FormField<String>(
        validator: widget.validator,
        builder: (state) {
          _errorText = state.errorText;
          return input;
        },
      );
    }

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
            child: input,
          ),
        ),
      ),
    );
  }
}