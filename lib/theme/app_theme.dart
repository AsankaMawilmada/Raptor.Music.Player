import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Visual language modeled on the "Lumina Audio" design system: a light,
/// glassmorphic, heavily-rounded look built on Inter typography with a
/// pink-to-orange vibrant gradient accent (see design/lumina_audio/DESIGN.md
/// in the reference mockups). Light tokens are lifted directly from that
/// spec; dark tokens are derived from its inverse-surface/inverse-primary
/// anchors since the mockups themselves are light-only.
class AppColors {
  // Light tokens (from DESIGN.md).
  static const lightBackground = Color(0xFFF8F9FA);
  static const lightSurface = Color(0xFFF8F9FA);
  static const lightSurfaceDim = Color(0xFFD9DADB);
  static const lightSurfaceBright = Color(0xFFF8F9FA);
  static const lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const lightSurfaceContainerLow = Color(0xFFF3F4F5);
  static const lightSurfaceContainer = Color(0xFFEDEEEF);
  static const lightSurfaceContainerHigh = Color(0xFFE7E8E9);
  static const lightSurfaceContainerHighest = Color(0xFFE1E3E4);
  static const lightOnSurface = Color(0xFF191C1D);
  static const lightOnSurfaceVariant = Color(0xFF5B3F44);
  static const lightOutline = Color(0xFF8F6F74);
  static const lightOutlineVariant = Color(0xFFE4BDC3);
  static const lightPrimary = Color(0xFFB7004F);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFE40A65);
  static const lightOnPrimaryContainer = Color(0xFFFFFBFF);
  static const lightSecondary = Color(0xFF004FD9);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightSecondaryContainer = Color(0xFF2A69FD);
  static const lightOnSecondaryContainer = Color(0xFFFEFCFF);
  static const lightError = Color(0xFFBA1A1A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF93000A);
  static const lightSurfaceStroke = Color(0xFFEEEEEE);
  static const lightGlassSurface = Color(0xB3FFFFFF); // rgba(255,255,255,0.7)

  // Dark tokens, derived from DESIGN.md's inverse-*/fixed anchors.
  static const darkBackground = Color(0xFF121417);
  static const darkSurface = Color(0xFF121417);
  static const darkSurfaceContainerLowest = Color(0xFF0B0D0F);
  static const darkSurfaceContainerLow = Color(0xFF1A1D20);
  static const darkSurfaceContainer = Color(0xFF1E2124);
  static const darkSurfaceContainerHigh = Color(0xFF292C2F);
  static const darkSurfaceContainerHighest = Color(0xFF34373A);
  static const darkOnSurface = Color(0xFFF0F1F2); // inverse-on-surface
  static const darkOnSurfaceVariant = Color(0xFFD4B8BD);
  static const darkOutline = Color(0xFF9C8489);
  static const darkOutlineVariant = Color(0xFF5B3F44);
  static const darkPrimary = Color(0xFFFFB1C0); // inverse-primary
  static const darkOnPrimary = Color(0xFF3F0017); // on-primary-fixed
  static const darkPrimaryContainer = Color(0xFF90003D); // on-primary-fixed-variant
  static const darkOnPrimaryContainer = Color(0xFFFFD9DF);
  static const darkSecondary = Color(0xFFB5C4FF); // secondary-fixed-dim
  static const darkOnSecondary = Color(0xFF00174C);
  static const darkSecondaryContainer = Color(0xFF003DAB);
  static const darkOnSecondaryContainer = Color(0xFFDBE1FF);
  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);
  static const darkSurfaceStroke = Color(0xFF2E3132);
  static const darkGlassSurface = Color(0xB32E3132); // rgba(46,49,50,0.7)

  // Vibrant gradient - identical in both themes (buttons, active progress,
  // active nav pill).
  static const vibrantGradientStart = Color(0xFFFF2D78);
  static const vibrantGradientEnd = Color(0xFFFF8C61);
}

class AppGradients {
  static const vibrant = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.vibrantGradientStart, AppColors.vibrantGradientEnd],
  );
}

/// Corner-radius scale (design tokens: sm 0.5rem, DEFAULT 1rem, md 1.5rem,
/// lg 2rem, xl 3rem, full = pill).
class AppRadii {
  static const sm = 8.0;
  static const dflt = 16.0;
  static const md = 24.0;
  static const lg = 32.0;
  static const xl = 48.0;
  static const full = 9999.0;
}

/// 8px-based spacing scale.
class AppSpacing {
  static const unit = 8.0;
  static const elementGap = 12.0;
  static const gutter = 16.0;
  static const sectionGap = 32.0;
  static const containerMargin = 24.0;
}

class AppTheme {
  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        onSurface: AppColors.lightOnSurface,
        onSurfaceVariant: AppColors.lightOnSurfaceVariant,
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightOnPrimary,
        primaryContainer: AppColors.lightPrimaryContainer,
        onPrimaryContainer: AppColors.lightOnPrimaryContainer,
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightOnSecondary,
        secondaryContainer: AppColors.lightSecondaryContainer,
        onSecondaryContainer: AppColors.lightOnSecondaryContainer,
        error: AppColors.lightError,
        onError: AppColors.lightOnError,
        errorContainer: AppColors.lightErrorContainer,
        onErrorContainer: AppColors.lightOnErrorContainer,
        surface: AppColors.lightSurface,
        surfaceContainerLowest: AppColors.lightSurfaceContainerLowest,
        surfaceContainerLow: AppColors.lightSurfaceContainerLow,
        surfaceContainer: AppColors.lightSurfaceContainer,
        surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
        outline: AppColors.lightOutline,
        outlineVariant: AppColors.lightOutlineVariant,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        onSurface: AppColors.darkOnSurface,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSecondary,
        secondaryContainer: AppColors.darkSecondaryContainer,
        onSecondaryContainer: AppColors.darkOnSecondaryContainer,
        error: AppColors.darkError,
        onError: AppColors.darkOnError,
        errorContainer: AppColors.darkErrorContainer,
        onErrorContainer: AppColors.darkOnErrorContainer,
        surface: AppColors.darkSurface,
        surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
        surfaceContainerLow: AppColors.darkSurfaceContainerLow,
        surfaceContainer: AppColors.darkSurfaceContainer,
        surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color primary,
    required Color onPrimary,
    required Color primaryContainer,
    required Color onPrimaryContainer,
    required Color secondary,
    required Color onSecondary,
    required Color secondaryContainer,
    required Color onSecondaryContainer,
    required Color error,
    required Color onError,
    required Color errorContainer,
    required Color onErrorContainer,
    required Color surface,
    required Color surfaceContainerLowest,
    required Color surfaceContainerLow,
    required Color surfaceContainer,
    required Color surfaceContainerHigh,
    required Color surfaceContainerHighest,
    required Color outline,
    required Color outlineVariant,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: secondary,
      onTertiary: onSecondary,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
    );

    final base = ThemeData(brightness: brightness, useMaterial3: true, colorScheme: scheme);

    final interBase = GoogleFonts.interTextTheme(base.textTheme);
    final textTheme = interBase.copyWith(
      displayLarge: interBase.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64,
        height: 40 / 32,
        color: onSurface,
      ),
      headlineLarge: interBase.headlineLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        height: 32 / 24,
        color: onSurface,
      ),
      headlineMedium: interBase.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: onSurface,
      ),
      titleMedium: interBase.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        color: onSurface,
      ),
      bodyLarge: interBase.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: onSurface,
      ),
      bodyMedium: interBase.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: onSurfaceVariant,
      ),
      labelMedium: interBase.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        height: 16 / 12,
        color: onSurfaceVariant,
      ),
      labelSmall: interBase.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 14 / 11,
        color: onSurfaceVariant,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: primary,
        unselectedLabelColor: onSurfaceVariant,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.labelMedium,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        iconColor: onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.dflt)),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.dflt)),
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.full)),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: onSurfaceVariant.withValues(alpha: 0.6)),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: surfaceContainerHighest,
      ),
      dividerColor: outlineVariant.withValues(alpha: 0.3),
      cardColor: surfaceContainerLowest,
    );
  }
}
