import 'package:flutter/material.dart';
import 'theme.dart';

/// Provides glass-morphism style decoration.
///
/// Creates a semi-transparent background with subtle border and optional hover glow.
class GlassDecoration extends BoxDecoration {
  GlassDecoration({
    Color? color,
    BorderRadius? borderRadius,
    bool isPrimary = false,
    bool isHovered = false,
  }) : super(
         color: color ?? _defaultGlassColor(isPrimary),
         borderRadius:
             borderRadius ?? BorderRadius.circular(GlassEffects.radius),
         border: _buildBorder(isPrimary, isHovered),
         boxShadow: isHovered ? _buildGlow(isPrimary) : null,
       );

  static Color _defaultGlassColor(bool isPrimary) {
    final base = Colors.white;
    return base.withValues(alpha: GlassEffects.opacity);
  }

  static Border? _buildBorder(bool isPrimary, bool isHovered) {
    final borderColor = Colors.white.withValues(
      alpha: GlassEffects.strokeOpacity,
    );
    return Border.all(color: borderColor, width: GlassEffects.strokeWidth);
  }

  static List<BoxShadow>? _buildGlow(bool isPrimary) {
    // Glow will be applied via primary color from theme, but we need that from context
    // This is simplified - actual glow color applied via Material state properties
    return [
      BoxShadow(
        color: Colors.transparent, // Will be overridden by Material state
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ];
  }
}

/// Utility to get glass surface color from theme with proper opacity.
Color getGlassSurfaceColor(ColorScheme scheme, {bool isPrimary = false}) {
  final base = isPrimary ? scheme.primary : scheme.surface;
  return base.withValues(alpha: GlassEffects.opacity);
}

/// Utility to get glass border stroke color.
Color getGlassBorderColor([double? alpha]) {
  return Colors.white.withValues(alpha: alpha ?? GlassEffects.strokeOpacity);
}

/// Utility to get glass text color (defaults to onSurface).
Color getGlassTextColor(ColorScheme scheme, {bool isPrimary = false}) {
  return scheme.onSurface;
}

/// Creates a glass-style outline input border.
GlassInputBorder glassOutlineInputBorder(
  ColorScheme scheme, {
  bool isPrimary = false,
}) {
  return GlassInputBorder._(
    borderSide: BorderSide(
      color: getGlassBorderColor(GlassEffects.strokeOpacity),
      width: GlassEffects.strokeWidth,
    ),
    borderRadius: BorderRadius.circular(GlassEffects.radius),
  );
}

/// Custom outline border with glass styling for InputDecoration.
class GlassInputBorder extends InputBorder {
  const GlassInputBorder._({
    this.borderSide = BorderSide.none,
    this.borderRadius = BorderRadius.zero,
    this.gapPadding = 4.0,
  });

  final BorderSide borderSide;
  final BorderRadius borderRadius;
  final double gapPadding;

  @override
  GlassInputBorder copyWith({
    BorderSide? borderSide,
    BorderRadius? borderRadius,
    double? gapPadding,
  }) {
    return GlassInputBorder._(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
      gapPadding: gapPadding ?? this.gapPadding,
    );
  }

  @override
  EdgeInsetsGeometry get innerMargin => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.resolve(textDirection).toRRect(rect));
  }

  @override
  EdgeInsetsGeometry getInnerPadding(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    return EdgeInsets.zero;
  }

  @override
  bool get isOutline => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
  }) {
    final RRect rrect = borderRadius.toRRect(rect);
    final Paint paint = borderSide.toPaint();
    canvas.drawRRect(rrect, paint);

    // Draw inner gradient stroke line
    if (borderSide.width > 0) {
      final Paint innerPaint = Paint()
        ..color = Colors.white.withValues(
          alpha: GlassEffects.strokeOpacity * 0.5,
        )
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      final innerRect = rect.deflate(borderSide.width);
      final RRect innerRrect = borderRadius.toRRect(innerRect);
      canvas.drawRRect(innerRrect, innerPaint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return GlassInputBorder._(
      borderSide: borderSide.scale(t),
      borderRadius: borderRadius * t,
      gapPadding: gapPadding * t,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
}
