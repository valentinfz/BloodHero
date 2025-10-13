import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Paleta de colores basada en el diseño de Figma
const Color _primaryColor = Color(0xFFC93B3B);
const Color _scaffoldBackgroundColor = Color(0xFFF5F5F5);
const Color _textColor = Color(0xFF333333);

class AppTheme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _scaffoldBackgroundColor,
        primaryColor: _primaryColor,
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textColor),
            bodyMedium: TextStyle(fontSize: 16, color: _textColor),
            labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}