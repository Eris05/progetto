import 'package:flutter/material.dart';

class CustomTheme {
  // Define primary colors
  static final Color orange = Color(0xFFFF6600);
  static final Color blue = Color(0xFF0066CC);
  static final Color white = Colors.white;
  static final Color black = Colors.black;

  // Define theme data
  static final ThemeData themeData = ThemeData(
    fontFamily: 'Roboto', // Set the global font family
    primaryColor: orange,
    scaffoldBackgroundColor: white,
    appBarTheme: AppBarTheme(
      backgroundColor: orange,
      foregroundColor: white, // Icon and text color
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: white,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        color: black,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: blue,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: blue,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: orange,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orange,
        foregroundColor: white,
        textStyle: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: blue,
        side: BorderSide(color: blue),
        textStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: blue.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: blue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: blue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: orange),
      ),
      labelStyle: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        color: blue,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: orange,
      primaryContainer: orange.withOpacity(0.8),
      secondary: blue,
      secondaryContainer: blue.withOpacity(0.8),
      surface: white,
      background: white,
      error: Colors.red,
      onPrimary: white,
      onSecondary: white,
      onSurface: black,
      onError: white,
    ),
  );
}
