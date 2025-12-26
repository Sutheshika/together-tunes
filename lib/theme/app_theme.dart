import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Teal + Purple Color Palette (Balanced, Sophisticated)
  static const Color darkTeal = Color(0xFF004D40); // Dark teal
  static const Color mediumTeal = Color(0xFF00796B); // Medium teal
  static const Color brightTeal = Color(0xFF009688); // Bright teal
  static const Color lightTeal = Color(0xFF26A69A); // Light teal
  static const Color primaryColor = Color(0xFF009688); // Primary teal
  static const Color secondaryColor = Color(0xFF7B1FA2); // Purple
  static const Color cyanAccent = Color(0xFF4DB8A8); // Light teal accent
  static const Color backgroundColor = Color(0xFF0D1B19); // Very dark teal
  static const Color surfaceColor = Color(0xFF132C2A); // Dark teal surface
  static const Color cardColor = Color(0xFF1A3A36); // Dark teal card
  static const Color textPrimary = Color(0xFFFFFFFF); // White text
  static const Color textSecondary = Color(0xFFA8D5CC); // Light teal text
  static const Color accent = Color(0xFF7B1FA2); // Purple accent
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color error = Color(0xFFEF5350); // Red

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: error,
    ),

    scaffoldBackgroundColor: backgroundColor,

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),

    cardTheme: const CardThemeData(
      color: cardColor,
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: cyanAccent.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      hintStyle: TextStyle(
        color: textSecondary,
        fontSize: 16,
      ),
      labelStyle: const TextStyle(
        color: textSecondary,
        fontSize: 16,
      ),
      contentPadding: const EdgeInsets.all(20),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 20,
    ),

    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      titleLarge: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      bodyLarge: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.poppins(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
    ),

    iconTheme: const IconThemeData(
      color: textPrimary,
      size: 24,
    ),

    dividerTheme: DividerThemeData(
      color: textSecondary.withOpacity(0.1),
      thickness: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardColor,
      contentTextStyle: const TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Gradient backgrounds - Teal + Purple (Balanced, Sophisticated)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkTeal, primaryColor, secondaryColor],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundColor, surfaceColor, darkTeal],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkTeal, primaryColor, lightTeal, secondaryColor],
  );

  static const LinearGradient lightBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, lightTeal, secondaryColor],
  );

  // NEW: Cyan accent gradient for special elements
  static const LinearGradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, cyanAccent],
  );

  // NEW: Glowing gradient for active states
  static const LinearGradient glowingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyanAccent, secondaryColor, cyanAccent],
  );

  // Custom shadows - Teal tinted with Purple glow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: darkTeal.withOpacity(0.25),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.4),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  // NEW: Glowing shadow for active/playing states
  static List<BoxShadow> get glowingShadow => [
    BoxShadow(
      color: secondaryColor.withOpacity(0.6),
      blurRadius: 25,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: secondaryColor.withOpacity(0.3),
      blurRadius: 40,
      offset: const Offset(0, 15),
    ),
  ];

  // NEW: Subtle glow for hover states
  static List<BoxShadow> get subtleGlow => [
    BoxShadow(
      color: cyanAccent.withOpacity(0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}