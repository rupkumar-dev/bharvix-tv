import 'package:bharvix_tv/core/app_colors.dart';
import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    useMaterial3: false,

    // ---------------- Colors ----------------
    scaffoldBackgroundColor: AppColors.bgColor,
    primaryColor: AppColors.accentColor,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentColor,
      secondary: AppColors.accentColor,
      surface: AppColors.cardColor,
    ),

    // ---------------- AppBar ----------------
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ---------------- Text ----------------
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
        fontSize: 13,
      ),
      bodySmall: TextStyle(
        color: Colors.white54,
        fontSize: 12,
      ),
    ),

    // ---------------- Inputs (Search) ----------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardColor,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIconColor: Colors.white54,
      suffixIconColor: Colors.white70,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),

    // ---------------- Tabs ----------------
    tabBarTheme: const TabBarThemeData(
      indicatorColor: AppColors.accentColor,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white54,
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
      ),
    ),

    // ---------------- Bottom Navigation ----------------
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardColor,
      selectedItemColor: AppColors.accentColor,
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    // ---------------- Cards ----------------
    cardTheme: CardThemeData(
      color: AppColors.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),

    // ---------------- Icons ----------------
    iconTheme: const IconThemeData(
      color: Colors.white70,
    ),

    // ---------------- Progress ----------------
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accentColor,
    ),
  );
}
