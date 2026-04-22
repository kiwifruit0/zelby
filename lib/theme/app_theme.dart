import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFFFFFFF);
  static const Color sidebarBackground = Color(0xFFFAFAFA);
  static const Color primary = Color(0xFF202020);
  static const Color muted = Color(0xFF888888);
  static const Color accent = Color(0xFFA692F5);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color hoverBackground = Color(0xFFF0F0F0);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    height: 1.4,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontSize: 14,
    color: AppColors.muted,
    height: 1.4,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontSize: 12,
    color: AppColors.muted,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 30,
    color: AppColors.primary,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static const TextStyle itemTitle = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    height: 1.4,
  );

  static const TextStyle itemMeta = TextStyle(
    fontSize: 12,
    color: AppColors.muted,
    height: 1.4,
  );

  static const TextStyle sidebarItem = TextStyle(
    fontSize: 15,
    color: AppColors.primary,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle sidebarItemMuted = TextStyle(
    fontSize: 14,
    color: AppColors.muted,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle sidebarHeader = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: false,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.accent,
  colorScheme: const ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: AppColors.primary,
    secondary: AppColors.accent,
    onSecondary: AppColors.primary,
    surface: AppColors.background,
    onSurface: AppColors.primary,
    outline: AppColors.divider,
  ),
  textTheme: const TextTheme(
    bodyMedium: AppTextStyles.body,
    bodySmall: AppTextStyles.itemMeta,
    labelSmall: AppTextStyles.sectionHeader,
    titleMedium: AppTextStyles.itemTitle,
  ),
  dividerTheme: const DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 1,
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    color: AppColors.background,
    shape: RoundedRectangleBorder(),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: InputBorder.none,
    filled: false,
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) return AppColors.accent;
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.primary),
    side: const BorderSide(color: AppColors.muted, width: 1.5),
    shape: const CircleBorder(),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      overlayColor: WidgetStateProperty.all(AppColors.hoverBackground),
    ),
  ),
  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
    minVerticalPadding: AppSpacing.xs,
    dense: true,
  ),
  scrollbarTheme: const ScrollbarThemeData(
    thumbVisibility: WidgetStatePropertyAll(false),
  ),
  splashFactory: NoSplash.splashFactory,
  highlightColor: AppColors.hoverBackground,
  hoverColor: AppColors.hoverBackground,
  focusColor: Colors.transparent,
);
