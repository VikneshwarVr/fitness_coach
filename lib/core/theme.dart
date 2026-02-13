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
  static TextTheme createTextTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    return GoogleFonts.interTextTheme(base).apply(
      bodyColor: brightness == Brightness.dark ? foreground : const Color(0xFF0A0A0A),
      displayColor: brightness == Brightness.dark ? foreground : const Color(0xFF0A0A0A),
    );
  }

  static ThemeData getTheme(Brightness brightness) {
    if (brightness == Brightness.dark) return darkTheme;
    return lightTheme;
  }

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: primaryForeground,
      secondary: primary,
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
        borderRadius: BorderRadius.all(Radius.circular(10)),
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
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foreground,
        side: const BorderSide(color: border),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    textTheme: createTextTheme(Brightness.dark),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: input,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(color: mutedForeground, fontSize: 14),
      prefixIconColor: mutedForeground,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: primaryForeground,
      secondary: Color(0xFFF5F5F5), // Secondary: #f5f5f5
      onSecondary: Color(0xFF0A0A0A),
      surface: Color(0xFFFAFAFA), // Background: #fafafa
      onSurface: Color(0xFF0A0A0A), // Text: #0a0a0a
      error: Color(0xFFDC2626),
      onError: Colors.white,
      surfaceContainer: Colors.white, // Cards: #ffffff
      onSurfaceVariant: Color(0xFF737373),
      outline: Color(0xFFE5E5E5), // Borders: #e5e5e5
    ),
    scaffoldBackgroundColor: const Color(0xFFFAFAFA),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      margin: EdgeInsets.zero,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFAFAFA),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF0A0A0A)),
      titleTextStyle: TextStyle(color: Color(0xFF0A0A0A), fontSize: 18, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF737373),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 10,
    ),
    textTheme: createTextTheme(Brightness.light),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5), // secondary color for light theme inputs
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: const TextStyle(color: Color(0xFF737373), fontSize: 14),
      prefixIconColor: const Color(0xFF737373),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: primary.withValues(alpha: 0.1),
      secondarySelectedColor: primary.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      labelStyle: const TextStyle(color: Color(0xFF0A0A0A), fontSize: 12),
      secondaryLabelStyle: const TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.bold),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
    ),
    elevatedButtonTheme: darkTheme.elevatedButtonTheme,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF0A0A0A),
        side: const BorderSide(color: Color(0xFFE5E5E5)),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
