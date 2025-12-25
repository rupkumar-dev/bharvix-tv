import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primaryPurple = Color(0xFF2B1B3F);
  static const Color secondaryPurple = Color(0xFF3A1C5A);

  // Accent (Indian Vibe)
  static const Color saffron = Color(0xFFE07A1F);
  static const Color saffronSoft = Color(0xFFF2C94C);

  // Backgrounds
  static const Color background = Color(0xFF0E0B14);
  static const Color surface = Color(0xFF1A1325);

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB8B3C7);
  static const Color textMuted = Color(0xFF8E889E);

  // Utility
  static const Color divider = Color(0xFF2E2740);
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);



}



class AppGradients {
  AppGradients._();

  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2B1B3F),
      Color(0xFF3A1C5A),
      Color(0xFFE07A1F),
    ],
  );

  static const RadialGradient appIcon = RadialGradient(
    radius: 0.8,
    colors: [
      Color(0xFFE07A1F),
      Color(0xFF3A1C5A),
      Color(0xFF0E0B14),
    ],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF2B1B3F), // Deep Purple
    Color(0xFF3A1C5A), // Royal Purple
    Color(0xFFE07A1F), // Saffron
  ],
);

static const LinearGradient cinematicGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF0E0B14), // Almost black
    Color(0xFF2B1B3F), // Deep Purple
    Color(0xFFE07A1F), // Soft Saffron
  ],
);

static const RadialGradient iconGradient = RadialGradient(
  center: Alignment.center,
  radius: 0.8,
  colors: [
    Color(0xFFE07A1F), // Saffron glow
    Color(0xFF3A1C5A), // Purple depth
    Color(0xFF0E0B14), // Dark edge
  ],
);

}

