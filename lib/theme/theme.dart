import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

/// Zendfast complete theme configuration
/// Provides Material 3 themes with comprehensive component styling
class ZendfastTheme {
  // Private constructor to prevent instantiation
  ZendfastTheme._();

  /// Light theme configuration
  static ThemeData light() {
    final colorScheme = ZendfastColors.lightColorScheme();
    final textTheme = ZendfastTextStyles.lightTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: ZendfastColors.lightBackground,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: ZendfastElevation.level0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: ZendfastElevation.level2,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),

      // Navigation Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: ZendfastElevation.level1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(ZendfastRadius.large),
            bottomRight: Radius.circular(ZendfastRadius.large),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: ZendfastElevation.level1,
        shape: ZendfastRadius.mediumShape,
        margin: ZendfastSpacing.allM,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: ZendfastElevation.level1,
          padding: const EdgeInsets.symmetric(
            horizontal: ZendfastSpacing.l,
            vertical: ZendfastSpacing.m,
          ),
          shape: ZendfastRadius.mediumShape,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: ZendfastSpacing.l,
            vertical: ZendfastSpacing.m,
          ),
          shape: ZendfastRadius.mediumShape,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: ZendfastSpacing.l,
            vertical: ZendfastSpacing.m,
          ),
          shape: ZendfastRadius.mediumShape,
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: ZendfastSpacing.m,
            vertical: ZendfastSpacing.s,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          padding: ZendfastSpacing.allS,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: ZendfastElevation.level3,
        shape: const RoundedRectangleBorder(
          borderRadius: ZendfastRadius.largeRadius,
        ),
      ),

      // Input Decoration Theme (TextField, TextFormField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: ZendfastSpacing.allM,
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        shape: ZendfastRadius.smallShape,
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: ZendfastElevation.level3,
        shape: ZendfastRadius.extraLargeShape,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: ZendfastElevation.level1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ZendfastRadius.extraLarge),
            topRight: Radius.circular(ZendfastRadius.extraLarge),
          ),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        deleteIconColor: colorScheme.onSurfaceVariant,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: textTheme.labelLarge,
        padding: ZendfastSpacing.allS,
        shape: ZendfastRadius.smallShape,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.12),
        thickness: 1,
        space: ZendfastSpacing.m,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData dark() {
    final colorScheme = ZendfastColors.darkColorScheme();
    final textTheme = ZendfastTextStyles.darkTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: ZendfastColors.darkBackground,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: ZendfastElevation.level0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        elevation: ZendfastElevation.level2,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: textTheme.labelMedium,
        unselectedLabelStyle: textTheme.labelMedium,
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        unselectedIconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),

      // Navigation Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: colorScheme.surface,
        elevation: ZendfastElevation.level1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(ZendfastRadius.large),
            bottomRight: Radius.circular(ZendfastRadius.large),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: ZendfastElevation.level1,
        shape: ZendfastRadius.mediumShape,
        margin: ZendfastSpacing.allM,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: ZendfastElevation.level1,
          padding: const EdgeInsets.symmetric(
            horizontal: ZendfastSpacing.l,
            vertical: ZendfastSpacing.m,
          ),
          shape: ZendfastRadius.mediumShape,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: ZendfastSpacing.l,
            vertical: ZendfastSpacing.m,
          ),
          shape: ZendfastRadius.mediumShape,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: ZendfastSpacing.l,
            vertical: ZendfastSpacing.m,
          ),
          shape: ZendfastRadius.mediumShape,
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: ZendfastSpacing.m,
            vertical: ZendfastSpacing.s,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          padding: ZendfastSpacing.allS,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: ZendfastElevation.level3,
        shape: const RoundedRectangleBorder(
          borderRadius: ZendfastRadius.largeRadius,
        ),
      ),

      // Input Decoration Theme (TextField, TextFormField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ZendfastRadius.smallRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: ZendfastSpacing.allM,
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        shape: ZendfastRadius.smallShape,
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: ZendfastElevation.level3,
        shape: ZendfastRadius.extraLargeShape,
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        elevation: ZendfastElevation.level1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(ZendfastRadius.extraLarge),
            topRight: Radius.circular(ZendfastRadius.extraLarge),
          ),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        deleteIconColor: colorScheme.onSurfaceVariant,
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: textTheme.labelLarge,
        padding: ZendfastSpacing.allS,
        shape: ZendfastRadius.smallShape,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.12),
        thickness: 1,
        space: ZendfastSpacing.m,
      ),
    );
  }
}
