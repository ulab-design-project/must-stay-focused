import 'package:flutter/material.dart';

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

Color hsvToRgb(double h, double s, double v, [double a = 1.0]) {
  return HSVColor.fromAHSV(a, h, s, v).toColor();
}

List<Color> generateColorSteps(Color primaryColor, {bool lighter = false}) {
  final hsv = HSVColor.fromColor(primaryColor);
  
  if (lighter) {
    // Generate lighter colors by moving value to 1.0 and then decreasing saturation
    return List.generate(5, (index) {
      double step = index / 4; // 0.0 to 1.0
      double v = hsv.value + (1.0 - hsv.value) * step;
      double s = hsv.saturation;
      if (v >= 1.0) {
        v = 1.0;
        // Optionally decrease saturation slightly to get closer to white
        s = hsv.saturation * (1.0 - step * 0.5);
      }
      return HSVColor.fromAHSV(1.0, hsv.hue, s, v).toColor();
    });
  } else {
    final step = hsv.value / 6.0; // Ensures the lowest value isn't 0 (pitch black)
    return List.generate(5, (index) {
      double v = hsv.value - (step * index);
      if (v < 0) v = 0;
      return HSVColor.fromAHSV(1.0, hsv.hue, hsv.saturation, v).toColor();
    });
  }
}

