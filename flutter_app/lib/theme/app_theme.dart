import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Açık tema
// ---------------------------------------------------------------------------
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF4a7fa5),
    secondary: const Color(0xFF4bbfcc),
    surface: const Color(0xFFf0f4f7),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFF1a2a3a),
  ),
  scaffoldBackgroundColor: const Color(0xFFf0f4f7),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1a2a3a),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4a7fa5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4a7fa5), width: 2),
    ),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4a7fa5),
      foregroundColor: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4a7fa5),
    foregroundColor: Colors.white,
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const Color(0xFF4a7fa5)
          : null,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1a2a3a),
    selectedItemColor: Color(0xFF4bbfcc),
    unselectedItemColor: Colors.white54,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: const Color(0xFF4a7fa5),
    labelStyle: const TextStyle(fontSize: 13),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFF4a7fa5)),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF4a7fa5),
    linearTrackColor: Color(0xFFd0dce8),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFd0dce8),
    thickness: 1,
  ),
);

// ---------------------------------------------------------------------------
// Koyu tema
// ---------------------------------------------------------------------------
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: const Color(0xFF4a7fa5),
    secondary: const Color(0xFF4bbfcc),
    surface: const Color(0xFF0e1825),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: const Color(0xFFd8e8f4),
  ),
  scaffoldBackgroundColor: const Color(0xFF0e1825),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0a1520),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF162030),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1a2a3a),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4a7fa5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4bbfcc), width: 2),
    ),
    hintStyle: const TextStyle(color: Colors.white38),
    labelStyle: const TextStyle(color: Colors.white70),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4a7fa5),
      foregroundColor: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4a7fa5),
    foregroundColor: Colors.white,
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const Color(0xFF4a7fa5)
          : null,
    ),
    checkColor: WidgetStateProperty.all(Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF0a1520),
    selectedItemColor: Color(0xFF4bbfcc),
    unselectedItemColor: Colors.white38,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFF1a2a3a),
    selectedColor: const Color(0xFF4a7fa5),
    labelStyle: const TextStyle(fontSize: 13, color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xFF4a7fa5)),
    ),
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: Color(0xFF4a7fa5),
    linearTrackColor: Color(0xFF1a2a3a),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFF1a2a3a),
    thickness: 1,
  ),
);
