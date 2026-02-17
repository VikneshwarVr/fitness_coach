import 'package:flutter/material.dart';

class Responsive {
  // Screen size detection
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  // Screen percentage helpers
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // Precision scaling based on a baseline (375 for mobile)
  // sp = Scalable Pixels (for fonts)
  static double sp(BuildContext context, double baseSize) {
    return screenWidth(context) * (baseSize / 375);
  }

  // p = Responsive Padding/Margin
  static double p(BuildContext context, double basePadding) {
    return screenWidth(context) * (basePadding / 375);
  }

  // w = Responsive Width
  static double w(BuildContext context, double baseWidth) {
    return screenWidth(context) * (baseWidth / 375);
  }

  // h = Responsive Height
  static double h(BuildContext context, double baseHeight) {
    return screenHeight(context) * (baseHeight / 812);
  }
}
