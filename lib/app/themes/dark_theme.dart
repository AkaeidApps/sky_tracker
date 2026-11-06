import 'package:flutter/material.dart';
import 'package:sky_tracker/app/constants/app_colors.dart';
import 'package:sky_tracker/app/constants/app_spacing.dart';
import 'package:sky_tracker/app/constants/app_text_styles.dart';

/// Dark theme for SkyTrack — the primary theme.
ThemeData getDarkTheme() {
  const scheme = ColorScheme.dark(
    primary: AppColors.accentPurple,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF2A1B4D),
    onPrimaryContainer: AppColors.accentViolet,
    secondary: AppColors.accentMagenta,
    onSecondary: Colors.white,
    surface: AppColors.secondaryBackground,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.elevatedSurface,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.borderStrong,
    outlineVariant: AppColors.border,
    error: AppColors.errorRed,
    onError: Colors.white,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.primaryBackground,
    canvasColor: AppColors.primaryBackground,
    dividerColor: AppColors.border,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
      headlineMedium: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
      headlineSmall: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
      titleLarge: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
      titleMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      titleSmall: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
      labelLarge: AppTextStyles.buttonLarge,
      labelMedium: AppTextStyles.label,
      labelSmall: AppTextStyles.overline,
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
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
      actionsIconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.elevatedSurface.withValues(alpha: 0.55),
      isDense: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.accentPurple, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      prefixIconColor: AppColors.textSecondary,
      suffixIconColor: AppColors.textSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentPurple,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.elevatedSurface,
        disabledForegroundColor: AppColors.textTertiary,
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
        backgroundColor: AppColors.accentPurple,
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
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.borderStrong),
        minimumSize: const Size(0, AppSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accentViolet,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: AppColors.accentViolet,
      textColor: AppColors.textPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      subtitleTextStyle: AppTextStyles.secondaryBodyMedium.copyWith(
        color: AppColors.textMuted,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.elevatedSurface,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      actionTextColor: AppColors.accentViolet,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.borderStrong),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.secondaryBackground,
      modalBackgroundColor: AppColors.secondaryBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      dragHandleColor: AppColors.borderStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.secondaryBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accentPurple,
      linearTrackColor: AppColors.border,
      circularTrackColor: AppColors.border,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentPurple;
        }
        return AppColors.borderStrong;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(Colors.white),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accentPurple;
        }
        return Colors.transparent;
      }),
      side: const BorderSide(color: AppColors.borderStrong, width: 1.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.elevatedSurface,
      selectedColor: AppColors.accentPurple.withValues(alpha: 0.18),
      side: const BorderSide(color: AppColors.border),
      labelStyle: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
      secondaryLabelStyle: AppTextStyles.label.copyWith(
        color: AppColors.accentViolet,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.elevatedSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      textStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      ),
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
