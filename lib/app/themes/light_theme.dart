import 'package:flutter/material.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';

/// Light theme for SkyTrack.
ThemeData getLightTheme() {
  const ink = Color(0xFF101426);
  const inkSecondary = Color(0xFF5C6076);
  const inkTertiary = Color(0xFF8A8FA6);
  const border = Color(0xFFE4E6F0);
  const borderStrong = Color(0xFFC9CCDA);
  const background = Color(0xFFF5F6FB);
  const surface = Colors.white;
  const primary = Color(0xFF6D28D9);
  const primarySoft = Color(0xFFEDE7FD);

  const scheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primarySoft,
    onPrimaryContainer: Color(0xFF3B0F86),
    secondary: Color(0xFFBE185D),
    onSecondary: Colors.white,
    surface: surface,
    onSurface: ink,
    surfaceContainerHighest: Color(0xFFF1F2F9),
    onSurfaceVariant: inkSecondary,
    outline: borderStrong,
    outlineVariant: border,
    error: Color(0xFFDC2626),
    onError: Colors.white,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    canvasColor: background,
    dividerColor: border,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displayLarge: AppTextStyles.h1.copyWith(color: ink),
      displayMedium: AppTextStyles.h2.copyWith(color: ink),
      displaySmall: AppTextStyles.h3.copyWith(color: ink),
      headlineMedium: AppTextStyles.h3.copyWith(color: ink),
      headlineSmall: AppTextStyles.h4.copyWith(color: ink),
      titleLarge: AppTextStyles.h4.copyWith(color: ink),
      titleMedium: AppTextStyles.bodyMedium.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      titleSmall: AppTextStyles.bodyMedium.copyWith(
        color: ink,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: ink),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: ink),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: inkSecondary),
      labelLarge: AppTextStyles.buttonLarge,
      labelMedium: AppTextStyles.label.copyWith(color: inkSecondary),
      labelSmall: AppTextStyles.overline.copyWith(color: inkTertiary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 4,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ink,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: ink, size: 22),
      actionsIconTheme: IconThemeData(color: ink, size: 22),
    ),
    cardTheme: CardThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: inkTertiary),
      prefixIconColor: inkSecondary,
      suffixIconColor: inkSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFEDEEF5),
        disabledForegroundColor: inkTertiary,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        minimumSize: const Size(0, AppSpacing.buttonHeight),
        textStyle: AppTextStyles.buttonLarge,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTextStyles.buttonLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: const BorderSide(color: borderStrong),
        minimumSize: const Size(0, AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),
    iconTheme: const IconThemeData(color: ink, size: 22),
    dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      iconColor: primary,
      textColor: ink,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      subtitleTextStyle: AppTextStyles.secondaryBodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: ink,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
      actionTextColor: AppColors.accentViolet,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      modalBackgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      dragHandleColor: borderStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: border),
      ),
      titleTextStyle: AppTextStyles.h3.copyWith(color: ink),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: inkSecondary),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: border,
      circularTrackColor: border,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return inkTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return borderStrong;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(Colors.white),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return Colors.transparent;
      }),
      side: const BorderSide(color: borderStrong, width: 1.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF3F4FA),
      selectedColor: primarySoft,
      side: const BorderSide(color: border),
      labelStyle: AppTextStyles.label.copyWith(color: inkSecondary),
      secondaryLabelStyle: AppTextStyles.label.copyWith(color: primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: border),
      ),
      textStyle: AppTextStyles.bodyMedium.copyWith(color: ink),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
        TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        TargetPlatform.linux: ZoomPageTransitionsBuilder(),
      },
    ),
  );
}
