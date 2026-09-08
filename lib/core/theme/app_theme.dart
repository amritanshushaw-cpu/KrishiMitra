import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KrishiMitra AI / AgriSense Pro Design System
/// Calibrated Minimal Green Palette & Apple-Grade Glassmorphism Architecture
class AppTheme {
  // ==========================================
  // HIGH-CONTRAST OLED DARK MODE PALETTE (Exact Spec)
  // ==========================================
  // --background: #0A0A0A (True Black)
  // --surface: #1A1A1A (Card Background)
  // --border: #333333 (Subtle Borders)
  // --text: #FFFFFF (Pure White - 19.8:1 contrast on #0A0A0A, 17.4:1 on #1A1A1A)
  // --text-secondary: #A3A3A3 (Grey)
  // --accent: #3B82F6 (Blue) or #10B981 (Green)
  static const Color darkBackground = Color(0xFF0A0A0A);  // #0A0A0A (True Black Canvas)
  static const Color darkSurface = Color(0xFF1A1A1A);     // #1A1A1A (Card Background)
  static const Color darkSurfaceElevated = Color(0xFF242424); // Card Hover / Elevation
  static const Color darkBorder = Color(0xFF333333);      // #333333 (Subtle Borders)
  static const Color darkBorderStrong = Color(0xFF4D4D4D); // Stronger Section Borders
  static const Color darkText = Color(0xFFFFFFFF);        // #FFFFFF (Pure White)
  static const Color darkTextSecondary = Color(0xFFA3A3A3);// #A3A3A3 (Grey)
  static const Color darkTextMuted = Color(0xFFA3A3A3);    // High-contrast secondary grey
  static const Color darkAccentGreen = Color(0xFF10B981);  // #10B981 (Vibrant Emerald Green)
  static const Color darkAccentBlue = Color(0xFF3B82F6);   // #3B82F6 (Electric Tech Blue)

  // Light Mode Tokens (Preserved)
  static const Color midnightTeal = Color(0xFF051F20); // Deepest botanical forest / text
  static const Color deepPine = Color(0xFF0B2B26);     // Dark pine teal
  static const Color slatePine = Color(0xFF163832);    // Slate pine
  static const Color forestMoss = Color(0xFF235347);   // Deep botanical moss / light brand
  static const Color softSage = Color(0xFF8EB69B);     // Soft sage eucalyptus / secondary accent
  static const Color mintDew = Color(0xFFDAF1DE);      // Luminous pale mint dew

  // Functional Accents
  static const Color goldAccent = Color(0xFFD4AF37);   // Brass / warm gold metallic ring accent
  static const Color goldAccentSoft = Color(0x28D4AF37);
  static const Color alertRose = Color(0xFFEF4444);    // High-contrast alert
  static const Color alertRoseSoft = Color(0x1FEF4444);
  static const Color amberWarning = Color(0xFFF59E0B); // Pest / Nutrient alert
  static const Color amberWarningSoft = Color(0x1FF59E0B);
  static const Color skyBlue = darkAccentBlue;         // Rain / Hydration telemetry
  static const Color skyBlueSoft = Color(0x1F3B82F6);
  static const Color neonMint = darkAccentGreen;       // Eye-catching bio-luminescent emerald
  static const Color vibrantEmerald = darkAccentGreen; // Vibrant modern agricultural emerald
  static const Color ambientSunlight = Color(0xFFF59E0B);

  // Backward-compatible design aliases mapped to the new high-contrast dark system
  static const Color forestGreen = forestMoss;
  static const Color forestGreenDark = deepPine;
  static const Color sproutGreen = softSage;
  static const Color emeraldLight = darkAccentGreen;
  static const Color mintSoft = mintDew;
  static const Color ivoryCanvas = Color(0xFFF7FCF8);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color sageBorder = Color(0x388EB69B);
  static const Color sageBorderHover = Color(0x808EB69B);

  // Text Tokens
  static const Color lightTextPrimary = midnightTeal;
  static const Color lightTextSecondary = slatePine;
  static const Color lightTextMuted = Color(0xB2235347);

  // Dark Text Tokens - Ensuring 15:1+ contrast ratio on dark backgrounds
  static const Color darkTextPrimary = darkText; // #FFFFFF (19.8:1 contrast on #0A0A0A)

  // Surface & Canvas Aliases
  static const Color darkCanvas = darkBackground; // #0A0A0A (True Black)
  static const Color darkCard = darkSurface;       // #1A1A1A (Card Background)
  static const Color darkCardHover = darkSurfaceElevated; // #242424
  static const Color cardBorderStrong = darkBorderStrong;
  static const Color cardBorder = darkBorder;
  static const Color accent = darkAccentGreen;
  static const Color accentSoft = Color(0x3310B981);
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color alertRed = alertRose;
  static const Color alertRedSoft = alertRoseSoft;
  static const Color warningAmber = amberWarning;
  static const Color warningAmberSoft = amberWarningSoft;
  static const Color card = darkSurface;
  static const Color canvas = darkBackground;

  // ==========================================
  // AMBIENT BACKGROUND GRADIENTS
  // ==========================================

  /// Organic Light Mode Ambient Gradient
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.40, 0.80, 1.0],
    colors: [
      Color(0xFFF8FCF9),
      mintDew,
      Color(0xFFE4F6E7),
      Color(0xFFCCE7D2),
    ],
  );

  /// True Black OLED Night Mode Gradient with Vibrant Ambient Backdrops (#0A0A0A Base)
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.35, 0.70, 1.0],
    colors: [
      Color(0xFF0C1814), // Subtle deep bio-emerald ambient bloom
      darkBackground,    // #0A0A0A True Black
      Color(0xFF0C141E), // Subtle deep electric tech blue ambient bloom
      darkBackground,    // #0A0A0A True Black
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

  /// Generates card decoration matching modern dark mode standards
  /// Technical: backdrop-filter: blur(10px), rgba backgrounds, layered cards
  static BoxDecoration glassCardDecoration({
    required bool isDark,
    double radius = 24.0,
    bool isHovered = false,
    bool hasGoldGlow = false,
    Color? customBorderColor,
  }) {
    if (isDark) {
      return BoxDecoration(
        color: isHovered
            ? const Color(0xFF242424).withValues(alpha: 0.84) // Elevated frosted surface
            : const Color(0xFF1A1A1A).withValues(alpha: 0.72), // Translucent rgba glass
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: customBorderColor ??
              (hasGoldGlow
                  ? darkAccentGreen.withValues(alpha: isHovered ? 0.65 : 0.40)
                  : const Color(0xFFFFFFFF).withValues(alpha: 0.12)), // Specular hairline border
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          if (hasGoldGlow)
            BoxShadow(
              color: darkAccentGreen.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
        ],
      );
    } else {
      return BoxDecoration(
        color: isHovered
            ? Colors.white
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: customBorderColor ??
              (hasGoldGlow
                  ? goldAccent.withValues(alpha: isHovered ? 0.60 : 0.40)
                  : const Color(0x141A3E31)), // Soft organic hairline border
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0C1A3E31), // Diffused organic botanical shadow
            blurRadius: 22,
            spreadRadius: 0,
            offset: const Offset(0, 6),
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
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkAccentGreen,
        secondary: darkAccentBlue,
        surface: darkSurface,
        error: alertRose,
        onPrimary: Colors.white,
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
        color: darkSurface,
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
          backgroundColor: darkAccentGreen,
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
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder, width: 1.2),
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
