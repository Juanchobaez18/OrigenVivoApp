import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Constantes visuales de la marca Origen Vivo
class OrigenVivoColors {
  static const Color verdePrimario = Color(0xFF0D2818);
  static const Color doradoAcento = Color(0xFFB8863B);
  static const Color cremaFondo = Color(0xFFF5EDE3);
  static const Color blancoTarjeta = Colors.white;

  // Colores de estado
  static const Color estadoPendienteBg = Color(0xFFFCEFD9);
  static const Color estadoPendienteFg = Color(0xFFE8A33D);
  
  static const Color estadoProduccionBg = Color(0xFFE3F0FC);
  static const Color estadoProduccionFg = Color(0xFF3D7BE8);

  static const Color estadoListoBg = Color(0xFFE3F5E6);
  static const Color estadoListoFg = Color(0xFF3FA34D);

  static const Color estadoCanceladoBg = Color(0xFFFCE8E6);
  static const Color estadoCanceladoFg = Color(0xFFD9383A);
}

class OrigenVivoTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: OrigenVivoColors.verdePrimario,
        onPrimary: Colors.white,
        secondary: OrigenVivoColors.doradoAcento,
        onSecondary: Colors.white,
        surface: OrigenVivoColors.blancoTarjeta,
        onSurface: OrigenVivoColors.verdePrimario,
        error: OrigenVivoColors.estadoCanceladoFg,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: OrigenVivoColors.cremaFondo,
      
      // Estilo de tipografía premium
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: OrigenVivoColors.verdePrimario,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: OrigenVivoColors.verdePrimario,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: OrigenVivoColors.verdePrimario,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF2C3E2D),
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF4A5D4C),
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: OrigenVivoColors.verdePrimario,
        ),
      ),

      // Estilo de los Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2D6C5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2D6C5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: OrigenVivoColors.doradoAcento, width: 1.5),
        ),
        labelStyle: TextStyle(color: OrigenVivoColors.verdePrimario.withValues(alpha: 0.6)),
      ),

      // Estilo de Tarjetas (Cards)
      cardTheme: CardThemeData(
        color: OrigenVivoColors.blancoTarjeta,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEADBC8), width: 0.8),
        ),
      ),

      // Botón principal
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: OrigenVivoColors.verdePrimario,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Chips de categorías
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: OrigenVivoColors.verdePrimario,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: OrigenVivoColors.verdePrimario,
        ),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFEADBC8)),
        ),
      ),
    );
  }
}
