import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppColors {
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFE5E5E5);
  static const grey400 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF616161);
  static const grey800 = Color(0xFF212121);
  static const errorRed = Color(0xFFB00020);
  static const successGreen = Color(0xFF1B5E20);
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
  static const double subtle = 0.04;
  static const double light = 0.08;
  static const double medium = 0.16;
  static const double strong = 0.48;
  static const double full = 1.0;
}

abstract final class AppTextStyles {
  static const _base = TextStyle(
    fontFamily: '.SF Pro Text',
    color: AppColors.black,
    letterSpacing: -0.2,
  );

  static final displayLarge = _base.copyWith(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static final titleLarge = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static final titleMedium = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  static final bodyLarge = _base.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w400,
  );

  static final bodyMedium = _base.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static final caption = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey600,
  );

  static final mono = _base.copyWith(
    fontFamily: 'Courier New',
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );
}

final cupertinoTheme = CupertinoThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.black,
  primaryContrastingColor: AppColors.white,
  barBackgroundColor: AppColors.white.withOpacity(0.92),
  scaffoldBackgroundColor: AppColors.white,
  textTheme: CupertinoTextThemeData(
    primaryColor: AppColors.black,
    textStyle: AppTextStyles.bodyLarge,
    navTitleTextStyle: AppTextStyles.titleMedium,
    navLargeTitleTextStyle: AppTextStyles.displayLarge,
    actionTextStyle: AppTextStyles.bodyLarge.copyWith(
      fontWeight: FontWeight.w500,
    ),
  ),
);

final materialTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: AppColors.black,
    onPrimary: AppColors.white,
    secondary: AppColors.grey600,
    onSecondary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.black,
    error: AppColors.errorRed,
  ),
  scaffoldBackgroundColor: AppColors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.black,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    centerTitle: true,
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
      textStyle: AppTextStyles.titleMedium,
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
  fontFamily: '.SF Pro Text',
);
