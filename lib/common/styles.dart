import 'package:flutter/material.dart';
import 'package:kenorider_driver/common/colormanager.dart';

TextStyle dividerTextStyle() {
  return const TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
  );
}

Divider dividerStyle() {
  return const Divider(
    color: Colors.grey,
    thickness: 1.5,
  );
}

EdgeInsets dividerPadding() {
  return const EdgeInsets.symmetric(vertical: 20.0);
}

ButtonStyle continueButtonStyle() {
  return ElevatedButton.styleFrom(
    shadowColor: Colors.transparent,
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );
}

BoxDecoration nocontinueButtonGradientDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: <Color>[
        ColorManager.buttonNoDecorationColor,
        ColorManager.buttonNoDecorationColor
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(30),
  );
}

TextStyle continueButtonTextStyle() {
  return const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
}

BoxDecoration continueButtonGradientDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: <Color>[
        ColorManager.buttonMainuserLeftColor,
        ColorManager.buttonMainuserRightColor
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(30),
  );
}

EdgeInsets appbarPadding() {
  return const EdgeInsets.symmetric(horizontal: 20);
}

EdgeInsets dividerTextPadding() {
  return const EdgeInsets.symmetric(horizontal: 8.0);
}
