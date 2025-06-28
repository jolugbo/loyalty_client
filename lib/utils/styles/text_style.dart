import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moniback/utils/constants/app_colors.dart';

class AppTextStyle {
  static TextStyle body(
      {Color? color,
      FontStyle,
      Decoration,
      double size = 14,
      FontWeight fontWeight = FontWeight.normal}) {
    return GoogleFonts.plusJakartaSans(
        fontSize: size,
        color: color ?? AppColor.dark,
        letterSpacing: 0.1,
        fontWeight: fontWeight,
        decoration: Decoration,
        fontStyle: FontStyle);
  }
}
