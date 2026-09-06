import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KrishiMitra AI / AgriSense Pro Design System
/// Calibrated Minimal Green Palette & Apple-Grade Glassmorphism Architecture
class AppTheme {
  // ==========================================
  // MINIMAL GREEN COLOR PALETTE (Exact Palette)
  // ==========================================
  static const Color midnightTeal = Color(0xFF051F20); // #051F20 - Deepest midnight forest / night canvas
  static const Color deepPine = Color(0xFF0B2B26);     // #0B2B26 - Dark pine teal / glass card base
  static const Color slatePine = Color(0xFF163832);    // #163832 - Slate pine / card elevation & hover
  static const Color forestMoss = Color(0xFF235347);   // #235347 - Deep botanical moss / primary brand
  static const Color softSage = Color(0xFF8EB69B);     // #8EB69B - Soft sage eucalyptus / secondary accent
  static const Color mintDew = Color(0xFFDAF1DE);      // #DAF1DE - Luminous pale mint dew / light canvas & highlights

  // Mockup Metallic & Functional Accents
  static const Color goldAccent = Color(0xFFD4AF37);   // #D4AF37 - Brass / warm gold metallic ring accent
  static const Color goldAccentSoft = Color(0x28D4AF37);// 16% Gold tint
  static const Color alertRose = Color(0xFFE53935);    // Pathogen / Disease critical
  static const Color alertRoseSoft = Color(0x1FE53935);// 12% Rose Tint
  static const Color amberWarning = Color(0xFFFB8C00); // Pest / Nutrient alert
  static const Color amberWarningSoft = Color(0x1FFB8C00);// 12% Amber Tint
  static const Color skyBlue = Color(0xFF1976D2);      // Rain / Hydration telemetry
  static const Color skyBlueSoft = Color(0x1F1976D2);  // 12% Sky Tint

  // Backwards-compatible design aliases mapped cleanly to the new palette
  static const Color forestGreen = forestMoss;         // #235347
  static const Color forestGreenDark = deepPine;       // #0B2B26
  static const Color sproutGreen = softSage;           // #8EB69B
  static const Color emeraldLight = softSage;          // #8EB69B
  static const Color mintSoft = mintDew;               // #DAF1DE
  static const Color ivoryCanvas = Color(0xFFF7FCF8);  // Crisp luminous canvas
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color sageBorder = Color(0x388EB69B);   // 22% Soft Sage hairline
  static const Color sageBorderHover = Color(0x808EB69B);

  // Text Tokens
  static const Color lightTextPrimary = midnightTeal;  // #051F20
  static const Color lightTextSecondary = slatePine;   // #163832
  static const Color lightTextMuted = Color(0xB2235347);// #235347 with 70% opacity

  static const Color darkCanvas = midnightTeal;        // #051F20
  static const Color darkCard = deepPine;              // #0B2B26
  static const Color darkCardHover = slatePine;        // #163832
  static const Color darkBorder = Color(0x388EB69B);   // 22% Soft Sage hairline
  static const Color darkBorderStrong = Color(0x668EB69B);
  static const Color cardBorderStrong = softSage;      // Reticle and strong borders
  static const Color cardBorder = sageBorder;
  static const Color accent = forestMoss;
  static const Color accentSoft = Color(0x338EB69B);
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color alertRed = alertRose;
  static const Color alertRedSoft = alertRoseSoft;
  static const Color warningAmber = amberWarning;
  static const Color warningAmberSoft = amberWarningSoft;
  static const Color card = deepPine;
  static const Color canvas = midnightTeal;
  static const Color darkTextPrimary = mintDew;        // #DAF1DE
  static const Color darkTextSecondary = softSage;     // #8EB69B
  static const Color darkTextMuted = Color(0xB28EB69B);// 70% Soft Sage

  // ==========================================
  // AMBIENT BACKGROUND GRADIENTS
  // ==========================================

  /// Organic Light Mode Ambient Gradient
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.40, 0.80, 1.0],
    colors: [
      Color(0xFFF8FCF9), // Luminous Dew
      mintDew,           // #DAF1DE Palette Canvas
      Color(0xFFE4F6E7), // Soft mint transition
      Color(0xFFCCE7D2), // Soft sage depth
    ],
  );

  /// Obsidian Night Mode Ambient Gradient (Deep Velvet with Slate Pine Glow)
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.35, 0.70, 1.0],
    colors: [
      slatePine,         // #163832 Slate pine ambient lighting
      deepPine,          // #0B2B26 Deep pine mid-tones
      midnightTeal,      // #051F20 Deepest midnight forest base
      Color(0xFF031415), // Deep velvet shadow
    ],
  );

  static BoxDecoration backgroundDecoration(bool isDark) {
    return BoxDecoration(
      gradient: isDark ? darkBackgroundGradient : lightBackgroundGradient,
    );
  }

  // ==========================================
  // APPLE-GRADE GLASSMORPHISM DECORATIONS
  // ==========================================

  /// Generates the frosted glass card decoration matching Apple visionOS/iOS standards
  static BoxDecoration glassCardDecoration({
    required bool isDark,
    double radius = 24.0,
    bool isHovered = false,
    bool hasGoldGlow = false,
    Color? customBorderColor,
  }) {
    if (isDark) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isHovered
                ? slatePine.withValues(alpha: 0.80)
                : deepPine.withValues(alpha: 0.65),
            isHovered
                ? deepPine.withValues(alpha: 0.75)
                : midnightTeal.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: customBorderColor ??
              (hasGoldGlow
                  ? goldAccent.withValues(alpha: isHovered ? 0.65 : 0.40)
                  : softSage.withValues(alpha: isHovered ? 0.40 : 0.20)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: midnightTeal.withValues(alpha: 0.50),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          if (hasGoldGlow)
            BoxShadow(
              color: goldAccent.withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 4),
            ),
        ],
      );
    } else {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isHovered
                ? Colors.white.withValues(alpha: 0.90)
                : Colors.white.withValues(alpha: 0.78),
            isHovered
                ? mintDew.withValues(alpha: 0.70)
                : mintDew.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: customBorderColor ??
              (hasGoldGlow
                  ? goldAccent.withValues(alpha: isHovered ? 0.60 : 0.40)
                  : Colors.white.withValues(alpha: isHovered ? 0.95 : 0.70)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: forestMoss.withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (hasGoldGlow)
            BoxShadow(
              color: goldAccent.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
        ],
      );
    }
  }

  // ==========================================
  // TYPOGRAPHY TOKENS
  // ==========================================

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

  // ==========================================
  // THEME DATA DEFINITIONS
  // ==========================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: mintDew,
      colorScheme: const ColorScheme.light(
        primary: forestMoss,
        secondary: softSage,
        surface: mintDew,
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
        color: Colors.white.withValues(alpha: 0.80),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: sageBorder, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: forestMoss,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestMoss,
          side: const BorderSide(color: sageBorderHover, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: midnightTeal,
      colorScheme: const ColorScheme.dark(
        primary: softSage,
        secondary: mintDew,
        surface: deepPine,
        error: alertRose,
        onPrimary: midnightTeal,
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
        color: deepPine.withValues(alpha: 0.70),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: softSage,
          foregroundColor: midnightTeal,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
          side: const BorderSide(color: darkBorderStrong, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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
