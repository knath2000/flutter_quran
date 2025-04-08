import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Define core colors based on the "Arabian night sky" theme
const Color primaryDark = Color(0xFF0B001A); // Deep purple/black
const Color secondaryDark = Color(0xFF1A0A38); // Slightly lighter purple/blue
const Color accentGold = Color(0xFFFFD700); // Gold accent
const Color textPrimary = Colors.white;
const Color textSecondary = Colors.white70;

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentGold, // Use gold for primary interactive elements
        secondary: accentGold,
        surface: secondaryDark, // Cards, dialogs background
        onPrimary: primaryDark, // Text/icons on gold buttons
        onSecondary: primaryDark,
        onSurface: textPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textPrimary, displayColor: textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark, // Match scaffold background
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: accentGold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark, // Text on button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      // Define other theme properties as needed (cardTheme, inputDecorationTheme, etc.)
    );
  }
}
