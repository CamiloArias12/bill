import 'package:flutter/material.dart';

abstract class StyleApp {
  late final Color primaryColor;
  late final Color backgroundColor;
  late final Color borderColor;
  late final Color mutedTextColor;

  ThemeData get theme;
}
