import 'package:flutter/material.dart';
import 'app_theme.dart';

ThemeData get darkTheme {
  return ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: AppColors.darkOnPrimaryContainer,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: AppColors.darkSurface,
      elevation: AppThemeConfig.appBarElevation,
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(
        color: Colors.grey.shade400,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      shape: AppThemeConfig.cardShape.copyWith(
        side: BorderSide(
          color: Colors.grey.shade800,
          width: AppThemeConfig.cardBorderWidth,
        ),
      ),
    ),
    
    // Dropdown Menu Theme
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(color: AppColors.darkOnSurface),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.darkSurface),
        shape: WidgetStateProperty.all(AppThemeConfig.inputShape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeConfig.inputBorderRadius),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        filled: false,
        fillColor: Colors.transparent,
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.darkOnSurface,
        ),
      ),
    ),
    
    // Text Theme
    textTheme: AppTextStyles.latoTextTheme
        .apply(
          bodyColor: AppColors.darkOnSurface,
          displayColor: AppColors.darkOnSurface,
        )
        .copyWith(
          titleLarge: AppTextStyles.titleLarge.copyWith(
            color: AppColors.darkOnSurface,
          ),
          labelLarge: AppTextStyles.labelLarge.copyWith(
            color: AppColors.darkOnSurface,
          ),
        ),
    
    // Primary Text Theme
    primaryTextTheme: AppTextStyles.latoTextTheme
        .apply(
          bodyColor: AppColors.darkOnSurface,
          displayColor: AppColors.darkOnSurface,
        )
        .copyWith(
          titleLarge: AppTextStyles.titleLarge.copyWith(
            color: AppColors.darkOnSurface,
          ),
          labelLarge: AppTextStyles.labelLarge.copyWith(
            color: AppColors.darkOnSurface,
          ),
        ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: AppTextStyles.hintText,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeConfig.inputBorderRadius),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      filled: true,
      fillColor: AppColors.darkSurface,
      labelStyle: AppTextStyles.inputLabel.copyWith(
        color: AppColors.darkOnSurface,
      ),
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.primaryColor),
    
    // Icon Button Theme
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.primaryColor),
        shape: WidgetStateProperty.all(AppThemeConfig.buttonShape),
      ),
    ),
  );
}