import 'dart:ui';
import 'package:flutter/material.dart';
import 'theme.dart';

class GlassElevatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? label;
  final bool isPrimary;

  const GlassElevatedButton({
    super.key,
    this.onPressed,
    this.icon,
    this.label,
    this.isPrimary = false,
  });

  @override
  State<GlassElevatedButton> createState() => _GlassElevatedButtonState();
}

class GlassPrimaryElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? icon;
  final Widget? label;

  const GlassPrimaryElevatedButton({
    super.key,
    this.onPressed,
    this.icon,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GlassElevatedButton(
      isPrimary: true,
      onPressed: onPressed,
      icon: icon,
      label: label,
    );
  }
}

class _GlassElevatedButtonState extends State<GlassElevatedButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final op = themeController.glassOpacity;
    final blur = themeController.glassBlur;
    
    Color baseColor = widget.isPrimary
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;

    Color bgColor;
    if (_isPressed) {
      bgColor = widget.isPrimary 
        ? theme.colorScheme.primary.withValues(alpha: op + 0.3)
        : theme.colorScheme.onSurface.withValues(alpha: op + 0.1);
    } else if (_isHovered) {
      bgColor = widget.isPrimary
        ? theme.colorScheme.secondary.withValues(alpha: op + 0.1)
        : theme.colorScheme.onSurface.withValues(alpha: op + 0.05);
    } else {
      bgColor = baseColor.withValues(alpha: op);
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) widget.icon!,
        if (widget.icon != null && widget.label != null) const SizedBox(width: 8),
        if (widget.label != null) widget.label!,
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
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
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

