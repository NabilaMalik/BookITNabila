import 'package:flutter/material.dart';

class RiveAppTheme {
  // Primary Colors
  static const Color lightGreen = Color(0xFF67B864); // Light Green
  static const Color purple = Color(0xFF820263); // Purple
  static const Color blue = Colors.blue; // Blue Accent
  static const Color navy = Color(0xFF17203A); // Navy

  // Neutral Colors
  static const Color blackType = Color(0xFF111111); // Black Text
  static const Color white = Color(0xFFFFFFFF); // White
  static const Color greyLight = Color(0xFFB0B0B0); // Light Grey
  static const Color greyDark = Color(0xFF505050); // Dark Grey

  // Additional Colors
  static const Color red = Color(0xFFD32F2F); // Red
  static const Color orange = Color(0xFFFFA726); // Orange
  static const Color yellow = Color(0xFFFFEB3B); // Yellow
  static const Color teal = Color(0xFF00897B); // Teal
  static const Color cyan = Color(0xFF00BCD4); // Cyan
  static const Color pink = Color(0xFFE91E63); // Pink

  // Shadow and Background Colors
  static const Color shadow = Color(0xFF4A5367);
  static const Color shadowDark = Color(0xFF000000);
  static const Color backgroundLight = Color(0xFFF2F6FF);
  static const Color backgroundDark = Color(0xFF25254B);
  static const Color backgroundNeutral = Color(0xFFF5F5F5); // Neutral Background

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color surfaceMuted = Color(0xFFE0E0E0);

  // Accent Colors
  static const Color accentGreen = Color(0xFF00C853);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color accentBlue = Color(0xFF2196F3);

  // Gradient Colors
  static const Gradient bluePurpleGradient = LinearGradient(
    colors: [Color(0xFF9C27B0),Color(0xFF2196F3), ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient Colors
  static const Gradient blueGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF64B5F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient greenGradient = LinearGradient(
    colors: [Color(0xFF43A047), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFFCE93D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFFFA726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF416FDF), // Blue
  onPrimary: Color(0xFFFFFFFF), // White
  secondary: Color(0xFF6EAEE7), // Light Blue
  onSecondary: Color(0xFFFFFFFF), // White
  error: Color(0xFFBA1A1A), // Red
  onError: Color(0xFFFFFFFF), // White
  background: Color(0xFFFCFDF6), // Light Background
  onBackground: Color(0xFF1A1C18), // Dark Text
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC), // Light Grey Outline
  surface: Color(0xFFF9FAF3), // Surface Color
  onSurface: Color(0xFF1A1C18), // Text on Surface
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF0A3161), // Dark Blue
  onPrimary: Color(0xFFFFFFFF), // White
  secondary: Color(0xFF38B6FF), // Sky Blue
  onSecondary: Color(0xFFFFFFFF), // White
  error: Color(0xFFCF6679), // Light Red
  onError: Color(0xFF000000), // Black
  background: Color(0xFF1E1E2C), // Dark Background
  onBackground: Color(0xFFECEFF4), // Light Text
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFF4E4E5F), // Dark Grey Outline
  surface: Color(0xFF2E2E3A), // Dark Surface
  onSurface: Color(0xFFECEFF4), // Text on Surface
);

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(lightColorScheme.primary),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      elevation: MaterialStateProperty.all<double>(4.0),
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(darkColorScheme.primary),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
      elevation: MaterialStateProperty.all<double>(4.0),
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  ),
);
