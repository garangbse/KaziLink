import 'package:flutter/material.dart';

class KaziLinkTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0B5FFF),
        brightness: Brightness.light,
        surface: const Color(0xFFF6F8FC),
      ),
      scaffoldBackgroundColor: const Color(0xFFF3F6FB),
      fontFamily: 'Roboto',
      useMaterial3: true,
    );
  }
}
