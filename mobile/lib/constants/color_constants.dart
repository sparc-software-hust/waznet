import 'package:flutter/material.dart';

class ColorConstants {
  // lazy init singleton
  static ColorConstants? _instance;
  ColorConstants._privateConstructor() {
    _instance = this;
  }
  factory ColorConstants() => _instance ?? ColorConstants._privateConstructor();

  // first typeface (montserrat)
  final Color primaryGreen = const Color(0xFF259E73);
  final Color primaryLightGreen = const Color(0xFFACEBD4);
  final Color primaryDarkGreen = const Color(0xFF2E4A21);
  final Color primaryOrange = const Color(0xFFF2BF87);
  final Color primaryWhite = const Color(0xFFFCFCFC);

  // second typeface (satoshi/nunito)
  final Color primaryGreen1 = const Color(0xFF329C1B);
  final Color primarySand1 = const Color(0xFFDAD78D);
  final Color primaryLightGreen1 = const Color(0xFFE8FCE3);
  final Color primaryGrey1 = const Color(0xFF72777A);
  final Color primaryWhite1 = Colors.white;
  final Color primaryBlack1 = const Color(0xFF090A0A);

  final Color textHeader = const Color(0xFF333334);
  final Color textSubHeader = const Color(0xFF666667);
  final Color textPlaceholder = const Color(0xFF808082);
  final Color bgDisabled = const Color(0xFFC1C1C2);
  final Color bgApp = const Color(0xFFF4F4F5);
  final Color textBold = const Color(0xFF1D1D1E);
  final Color textChild = const Color(0xFF4D4D4E);
  final Color bgClickable = const Color(0xFF4CAF50);
  final Color border = const Color(0xFFE3E3E5);


  Color primary(isDark) => isDark ? const Color(0xFF33BACA) : const Color(0xFF05AABD);

  TextStyle fastStyle(int fontSize, FontWeight fontWeight, Color color) {
    return TextStyle(
      color: color,
      fontSize: fontSize.toDouble(),
      fontWeight: fontWeight,
      // fontFamily: "Inter",
      // letterSpacing: 0.1
    );
  }

    TextStyle placeholderStyle() => fastStyle(14, FontWeight.w400, textPlaceholder);
    TextStyle highlightPlaceHolderStyle() => fastStyle(14, FontWeight.w500, textSubHeader);
}
