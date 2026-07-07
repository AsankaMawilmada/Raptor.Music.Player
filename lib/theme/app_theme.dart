import 'package:flutter/material.dart';

/// Visual language modeled on Samsung Music (One UI): a bright blue accent,
/// flat list rows with circular/rounded artwork thumbnails, a top tab bar
/// (Tracks / Playlists / Albums / Artists / Folders) rather than a bottom
/// nav bar, and a docked mini-player.
class AppColors {
  static const accent = Color(0xFF1A73E8);
  static const accentDark = Color(0xFF4FA0FF);

  static const lightBg = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F5F7);
  static const darkBg = Color(0xFF121212);
  static const darkSurface = Color(0xFF1E1E1E);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: AppColors.accent,
      scaffoldBackgroundColor: AppColors.lightBg,
    );
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.lightBg,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: AppColors.accent,
        unselectedLabelColor: Colors.black54,
        indicatorColor: AppColors.accent,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        iconColor: Colors.black54,
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: AppColors.accent,
        thumbColor: AppColors.accent,
        inactiveTrackColor: Colors.black12,
      ),
      dividerColor: Colors.black12,
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorSchemeSeed: AppColors.accentDark,
      scaffoldBackgroundColor: AppColors.darkBg,
    );
    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: AppColors.accentDark,
        unselectedLabelColor: Colors.white60,
        indicatorColor: AppColors.accentDark,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      listTileTheme: base.listTileTheme.copyWith(
        iconColor: Colors.white70,
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: AppColors.accentDark,
        thumbColor: AppColors.accentDark,
        inactiveTrackColor: Colors.white24,
      ),
      dividerColor: Colors.white12,
      cardColor: AppColors.darkSurface,
    );
  }
}
