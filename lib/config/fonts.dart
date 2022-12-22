import 'package:flutter/material.dart';

class FontFamily {
  static const String fontFamily = "AvenirNext";

  static TextStyle DemiBold({Color? color, double? size, double? lineHeight}) =>
      TextStyle(
          fontFamily: fontFamily,
          fontSize: size ?? 20,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.black,
          height: lineHeight ?? 0);

  static TextStyle Regular({Color? color, double? size, double? lineHeight}) =>
      TextStyle(
          fontFamily: fontFamily,
          fontSize: size ?? 14,
          fontWeight: FontWeight.w400,
          color: color ?? Colors.black,
          height: lineHeight ?? 0);

  static TextStyle normal({Color? color, double? size, double? lineHeight}) =>
      TextStyle(
          fontFamily: fontFamily,
          fontSize: size ?? 16,
          fontWeight: FontWeight.w500,
          color: color ?? Colors.black,
          height: lineHeight ?? 0);
}
