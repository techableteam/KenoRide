import 'package:flutter/material.dart';

class ColorManager {
  static Color hextocolor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  static Color primarycolor = hextocolor("#0090A0");
  static Color primary50color = hextocolor("#C5F9FF");
  static Color darkprimarycolor = hextocolor("#00393B");
  static Color primary10color = hextocolor("#BCECF1");
  static Color buttonNoDecorationColor = hextocolor("#BCECF1");
  static const Color submitButtonGradientLeftColor = Color(0xFFE8EAE9);
  static const Color submitButtonGradientRightColor = Color(0xFF838483);
  static Color buttonLoginBackgroundColor = hextocolor("#0090A0");
  static Color primaryGeryColor = hextocolor("#EAEEF1");
  static Color primaryWhiteColor = hextocolor("#FEFCF6");
  static Color buttonMainuserLeftColor = hextocolor("#00393B");
  static Color buttonStarColor = hextocolor("#FFC107");
  static Color buttonMainuserRightColor = hextocolor("#009CA1");
}
