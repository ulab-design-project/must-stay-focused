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

List<Color> generatePriorityColors(Color primaryColor) {
  final hsv = HSVColor.fromColor(primaryColor);
  final step = hsv.value / 6.0; // Ensures the lowest value isn't 0 (pitch black)
  return List.generate(5, (index) {
    double v = hsv.value - (step * index);
    if (v < 0) v = 0;
    return HSVColor.fromAHSV(1.0, hsv.hue, hsv.saturation, v).toColor();
  });
}

