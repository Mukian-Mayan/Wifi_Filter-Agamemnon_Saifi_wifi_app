import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Color(0xFF070B12);
  static const Color surface = Color(0xFF0E1421);
  static const Color surface2 = Color(0xFF131C2C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color cloud = Color(0xFFE7ECF5);
  static const Color mist = Color(0xFF8B95AC);
  static const Color faint = Color(0xFF49536A);

  static const Color cyan = Color(0xFF00E6C3);
  static const Color cyanSoft = Color(0xFF5FFFE6);
  static const Color cyanDeep = Color(0xFF009E86);

  static const Color violet = Color(0xFF7B61FF);
  static const Color violetSoft = Color(0xFFA78BFA);
  static const Color violetDeep = Color(0xFF4B3BC9);

  static const Color coral = Color(0xFFFF5470);
  static const Color coralSoft = Color(0xFFFF8095);
  static const Color coralDeep = Color(0xFFC93A53);

  static const LinearGradient brand = LinearGradient(
    colors: [cyan, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient alert = LinearGradient(
    colors: [coral, violet],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppRadius {
  static const double sm = 12;
  static const double md = 18;
  static const double lg = 26;
  static const double xl = 34;
}

class AppGap {
  static const double xs = 6;
  static const double s = 12;
  static const double m = 18;
  static const double l = 26;
  static const double xl = 38;
}

class AppText {
  static TextStyle display(Color c) => TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: c, letterSpacing: -0.6, height: 1.04);
  static TextStyle h1(Color c) => TextStyle(fontSize: 23, fontWeight: FontWeight.w700, color: c, letterSpacing: -0.3);
  static TextStyle h2(Color c) => TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c, letterSpacing: -0.1);
  static TextStyle body(Color c) => TextStyle(fontSize: 14.5, fontWeight: FontWeight.w400, color: c, height: 1.45);
  static TextStyle label(Color c) => TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c, letterSpacing: 0.2);
  static TextStyle micro(Color c) => TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c, letterSpacing: 0.8);
}

class Palette {
  final bool dark;
  const Palette(this.dark);

  Color get bg => dark ? AppColors.black : const Color(0xFFEFF3FA);
  Color get surface => dark ? AppColors.surface : Colors.white;
  Color get surface2 => dark ? AppColors.surface2 : const Color(0xFFE6ECF6);
  Color get text => dark ? AppColors.cloud : const Color(0xFF161E2C);
  Color get textDim => dark ? AppColors.mist : const Color(0xFF5B6678);
  Color get faint => dark ? AppColors.faint : const Color(0xFF9AA4B6);
  Color get border => dark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.07);
  Color get glow => dark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08);

  static Palette of(BuildContext c) => Palette(Theme.of(c).brightness == Brightness.dark);
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.black,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.cyan,
      secondary: AppColors.violet,
      error: AppColors.coral,
      surface: AppColors.surface,
    ),
    splashColor: AppColors.cyan.withOpacity(0.08),
    highlightColor: Colors.transparent,
    dividerColor: Colors.white.withOpacity(0.06),
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFEFF3FA),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.cyanDeep,
      secondary: AppColors.violet,
      error: AppColors.coral,
      surface: Colors.white,
    ),
    splashColor: AppColors.cyanDeep.withOpacity(0.08),
    highlightColor: Colors.transparent,
    dividerColor: Colors.black.withOpacity(0.06),
  );
}

Color riskColor(int score) {
  if (score >= 70) return AppColors.cyan;
  if (score >= 40) return AppColors.violet;
  return AppColors.coral;
}
