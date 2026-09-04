import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KrishiMitra AI / AgriSense Pro Design System
/// Mobile and dashboard theme tokens for field operations.
class AppTheme {
  // Organic Light Palette
  static const Color forestGreen = Color(0xFF1B4D3E);     // Deep Forest Green (Primary Brand)
  static const Color forestGreenDark = Color(0xFF13382D); // Deep Shadow Forest
  static const Color sproutGreen = Color(0xFF40916C);     // Sprout / Leaf Green
  static const Color emeraldLight = Color(0xFF52B788);    // Emerald Accent (#52B788)
  static const Color mintSoft = Color(0xFFD8F3DC);        // 15% Mint tint
  static const Color ivoryCanvas = Color(0xFFF6F8F5);     // Warm, non-glare organic canvas
  static const Color pureWhite = Color(0xFFFFFFFF);       // Floating card surface
  static const Color sageBorder = Color(0xFFE2E9E2);      // Subtle 1px sage border
  static const Color sageBorderHover = Color(0xFFCBD5CB); // Stronger border
  static const Color lightTextPrimary = Color(0xFF192820);// Rich deep green-black text
  static const Color lightTextSecondary = Color(0xFF4D6154); // Muted body text
  static const Color lightTextMuted = Color(0xFF7D9284);  // Caption / Monospace text

  // Obsidian Dark Palette (High-contrast night field mode)
  static const Color darkCanvas = Color(0xFF090D0A);      // Deep obsidian night canvas
  static const Color darkCard = Color(0xFF111C15);        // Elevated card surface
  static const Color darkCardHover = Color(0xFF18281F);   // Active card
  static const Color darkBorder = Color(0xFF1E3326);      // Subtle dark border
  static const Color darkBorderStrong = Color(0xFF2E4E3B);// Active dark hairline
  static const Color darkTextPrimary = Color(0xFFF1F7F3); // High-contrast text
  static const Color darkTextSecondary = Color(0xFF9FB5A7); // Muted body
  static const Color darkTextMuted = Color(0xFF6B8273);   // Technical captions

  // Calibrated Functional Accents
  static const Color skyBlue = Color(0xFF1976D2);         // Hydration / Rain / AI Insights
  static const Color skyBlueSoft = Color(0x1F1976D2);     // 12% Sky Tint
  static const Color alertRose = Color(0xFFE53935);       // Pathogen / Disease Critical
  static const Color alertRoseSoft = Color(0x1FE53935);   // 12% Rose Tint
  static const Color amberWarning = Color(0xFFFB8C00);   // Pest / Nutrient Alert
  static const Color amberWarningSoft = Color(0x1FFB8C00);// 12% Amber Tint
  static const Color goldScore = Color(0xFFF4A261);       // Health score accent

  // Technical Monospace Typography (JetBrainsMono)
  static TextStyle monoHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.jetBrainsMono(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
      color: isDark ? darkTextPrimary : lightTextPrimary,
    );
  }

  static TextStyle monoLabel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.jetBrainsMono(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: isDark ? darkTextMuted : lightTextMuted,
    );
  }

  static TextStyle monoValue(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.jetBrainsMono(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: isDark ? darkTextPrimary : lightTextPrimary,
    );
  }

  /// Organic Light Theme (Default SaaS experience)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ivoryCanvas,
      colorScheme: const ColorScheme.light(
        primary: forestGreen,
        secondary: emeraldLight,
        surface: pureWhite,
        error: alertRose,
        onPrimary: Colors.white,
        onSurface: lightTextPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ).copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: lightTextPrimary,
          letterSpacing: -0.8,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
          letterSpacing: -0.5,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: lightTextPrimary,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: lightTextSecondary,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: lightTextMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: pureWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: sageBorder, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ivoryCanvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestGreen,
          side: const BorderSide(color: sageBorderHover, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  /// Obsidian Dark Theme (High-contrast Night field mode)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkCanvas,
      colorScheme: const ColorScheme.dark(
        primary: emeraldLight,
        secondary: emeraldLight,
        surface: darkCard,
        error: alertRose,
        onPrimary: Colors.black,
        onSurface: darkTextPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: darkTextPrimary,
          letterSpacing: -0.8,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
          letterSpacing: -0.5,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: darkTextPrimary,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: darkTextSecondary,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: darkTextMuted,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCanvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldLight,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorderStrong, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
