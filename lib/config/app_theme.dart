import 'package:flutter/material.dart';

class AppTheme {
  // Exact WebApp colors
  static const Color primaryBlue = Color(0xFF6EA8D5);
  static const Color primaryBlueHover = Color(0xFF5a94c0);
  static const Color green = Color(0xFF3BAD5A);
  static const Color greenHover = Color(0xFF2d9248);
  static const Color orange = Color(0xFFF4A100);
  static const Color orangeHover = Color(0xFFE8920C);
  static const Color red = Color(0xFFDC3545);
  static const Color pendingOrange = Color(0xFFE67E22);
  static const Color otpRed = Color(0xFFE53935);

  static const Color cardBorder = Color(0xFFD0E4F7);
  static const Color cardBg = Colors.white;
  static const Color lightBlueBg = Color(0xFFF0F6FC);
  static const Color pageBg = Color(0xFFF5F5F5);
  static const Color startPageBg = Color(0xFFF0F0F8);

  static const Color textDark = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textTertiary = Color(0xFF888888);
  static const Color textHint = Color(0xFF999999);
  static const Color headerBlue = Color(0xFF1A5FA8);
  static const Color detailBorder = Color(0xFFEEEEEE);

  static const double maxBodyWidth = 480;
  static const double cardRadius = 12;
  static const double buttonRadius = 30;

  static ThemeData get theme => ThemeData(
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: pageBg,
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: green,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Color(0x26000000),
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Segoe UI',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Segoe UI',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryBlue,
            side: const BorderSide(color: primaryBlue, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(buttonRadius),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCED4DA)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCED4DA)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: red),
          ),
          labelStyle: const TextStyle(
            color: textTertiary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: const TextStyle(color: textHint),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
            side: const BorderSide(color: cardBorder, width: 1.5),
          ),
          margin: const EdgeInsets.only(bottom: 16),
        ),
      );
}
