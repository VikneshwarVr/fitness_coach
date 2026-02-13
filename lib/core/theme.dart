import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors mapped from theme.css
  static const Color primary = Color(0xFFEA580C); // orange-600
  static const Color primaryForeground = Colors.white;
  
  static const Color background = Color(0xFF0A0A0A);
  static const Color foreground = Color(0xFFFAFAFA); // oklch(0.985 0 0)
  
  static const Color card = Color(0xFF121212);
  static const Color cardForeground = Color(0xFFFAFAFA);
  
  static const Color muted = Color(0xFF1A1A1A);
  static const Color mutedForeground = Color(0xFFA1A1AA); // Approximate for oklch(0.608 0 0)
  
  static const Color border = Color(0xFF1F1F1F);
  static const Color input = Color(0xFF1A1A1A);
  
  static const Color destructive = Color(0xFFCF6679); // Material default error
  static const Color destructiveForeground = Colors.white;

  // Typography
  static final TextTheme textTheme = GoogleFonts.interTextTheme(
    ThemeData.dark().textTheme,
  ).apply(
    bodyColor: foreground,
    displayColor: foreground,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: primaryForeground,
      secondary: primary, // Using primary as secondary for now
      onSecondary: primaryForeground,
      surface: background,
      onSurface: foreground,
      error: destructive,
      onError: destructiveForeground,
      surfaceContainer: card,
      onSurfaceVariant: mutedForeground,
      outline: border,
    ),
    scaffoldBackgroundColor: background,
    cardTheme: const CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: border),
        borderRadius: BorderRadius.all(Radius.circular(10)), // --radius: 0.625rem
      ),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: card,
      selectedItemColor: primary,
      unselectedItemColor: mutedForeground,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: primaryForeground,
        minimumSize: const Size(double.infinity, 56), // h-14
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        side: const BorderSide(color: border),
        minimumSize: const Size(double.infinity, 48), // h-12
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: border),
      ),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: foreground,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14,
        color: mutedForeground,
      ),
    ),
    textTheme: textTheme,
  );
}
