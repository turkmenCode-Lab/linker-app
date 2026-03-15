import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppColors {
  static const black = Color(0xFF080808);
  static const white = Color(0xFFFAFAFA);
  static const darkBg = Color(0xFF111111);
  static const darkSurface = Color(0xFF1C1C1C);
  static const darkSurface2 = Color(0xFF282828);
  static const darkText = Color(0xFFF8F8F8);
  static const darkTextSecondary = Color(0xFFCCCCCC);
  static const darkDivider = Color(0xFF383838);
  static const grey100 = Color(0xFFF2F2F2);
  static const grey200 = Color(0xFFD0D0D0);
  static const grey400 = Color(0xFF555555);
  static const grey600 = Color(0xFF333333);
  static const grey800 = Color(0xFF1E1E1E);
  static const errorRed = Color(0xFFE53935);
  static const errorRedDark = Color(0xFFEF5350);
  static const successGreen = Color(0xFF2E7D32);
  static const successGreenDark = Color(0xFF66BB6A);
}

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppOpacity {
  static const double subtle = 0.05;
  static const double light = 0.1;
  static const double medium = 0.18;
  static const double strong = 0.5;
  static const double full = 1.0;
}

abstract final class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: AppColors.black,
    height: 1.1,
  );

  static TextStyle get titleLarge => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.black,
  );

  static TextStyle get titleMedium => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.black,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.4,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.4,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.grey600,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static TextStyle get mono => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
    height: 1.5,
  );
}

final materialTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.black,
    onPrimary: AppColors.white,
    secondary: AppColors.grey600,
    onSecondary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.black,
    surfaceContainerHighest: Color(0xFFEEEEEE),
    error: AppColors.errorRed,
  ),
  scaffoldBackgroundColor: AppColors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.black,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    centerTitle: true,
    titleTextStyle: AppTextStyles.titleMedium,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.grey100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.black, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.errorRed),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
      elevation: 0,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.black,
      textStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.grey200,
    thickness: 0.5,
    space: 0,
  ),
  textTheme: GoogleFonts.interTextTheme(),
);

final materialThemeDark = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.darkText,
    onPrimary: AppColors.darkBg,
    secondary: AppColors.darkTextSecondary,
    onSecondary: AppColors.darkBg,
    surface: AppColors.darkSurface,
    onSurface: Color(0xFFF8F8F8),
    surfaceContainerHighest: AppColors.darkSurface2,
    error: AppColors.errorRedDark,
  ),
  scaffoldBackgroundColor: AppColors.darkBg,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkBg,
    foregroundColor: AppColors.darkText,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    centerTitle: true,
    titleTextStyle: AppTextStyles.titleMedium.copyWith(
      color: AppColors.darkText,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.darkText, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.errorRedDark),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkText,
      foregroundColor: AppColors.darkBg,
      minimumSize: const Size(double.infinity, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTextStyles.titleMedium.copyWith(color: AppColors.darkBg),
      elevation: 0,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.darkText,
      textStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.darkDivider,
    thickness: 0.5,
    space: 0,
  ),
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
);

CupertinoThemeData cupertinoThemeFor(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return CupertinoThemeData(
    brightness: brightness,
    primaryColor: isDark ? AppColors.darkText : AppColors.black,
    primaryContrastingColor: isDark ? AppColors.darkBg : AppColors.white,
    barBackgroundColor: (isDark ? AppColors.darkBg : AppColors.white)
        .withOpacity(0.94),
    scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.white,
    textTheme: CupertinoTextThemeData(
      primaryColor: isDark ? AppColors.darkText : AppColors.black,
      textStyle: AppTextStyles.bodyLarge.copyWith(
        color: isDark ? AppColors.darkText : AppColors.black,
      ),
      navTitleTextStyle: AppTextStyles.titleMedium.copyWith(
        color: isDark ? AppColors.darkText : AppColors.black,
      ),
      navLargeTitleTextStyle: AppTextStyles.displayLarge.copyWith(
        color: isDark ? AppColors.darkText : AppColors.black,
      ),
      actionTextStyle: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.darkText : AppColors.black,
      ),
    ),
  );
}
