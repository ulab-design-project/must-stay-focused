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
