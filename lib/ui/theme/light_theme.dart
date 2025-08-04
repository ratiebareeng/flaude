import 'package:flutter/material.dart';
import 'app_theme.dart';

ThemeData get lightTheme {
  return ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
    
    // AppBar Theme
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: AppColors.lightSurface,
      elevation: AppThemeConfig.appBarElevation,
      titleTextStyle: AppTextStyles.appBarTitle.copyWith(
        color: Colors.grey.shade400,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      shape: AppThemeConfig.cardShape.copyWith(
        side: BorderSide(
          color: Colors.grey.shade800,
          width: AppThemeConfig.cardBorderWidth,
        ),
      ),
    ),
    
    // Dropdown Menu Theme
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: TextStyle(color: AppColors.lightOnSurface),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.lightSurface),
        shape: WidgetStateProperty.all(AppThemeConfig.inputShape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeConfig.inputBorderRadius),
          borderSide: const BorderSide(color: Colors.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeConfig.inputBorderRadius),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppThemeConfig.inputBorderRadius),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        filled: true,
        fillColor: AppColors.lightSurface,
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.lightOnSurface,
        ),
      ),
    ),
    
    // Text Theme
    textTheme: AppTextStyles.latoTextTheme.copyWith(
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: AppColors.lightOnSurface,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: AppColors.lightOnSurface,
      ),
    ),
    
    // Primary Text Theme
    primaryTextTheme: AppTextStyles.latoTextTheme.copyWith(
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: AppColors.lightOnSurface,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: AppColors.lightOnSurface,
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      focusColor: AppColors.primaryColor,
      hintStyle: AppTextStyles.hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeConfig.inputBorderRadius),
        borderSide: const BorderSide(color: Colors.white),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeConfig.inputBorderRadius),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppThemeConfig.inputBorderRadius),
        borderSide: const BorderSide(color: Colors.blue),
      ),
      filled: true,
      fillColor: AppColors.lightInputFill,
      labelStyle: AppTextStyles.inputLabel.copyWith(
        color: AppColors.lightOnSurface,
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