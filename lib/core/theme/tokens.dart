import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF242424);
  static const pink = Color(0xFFEE5B9A);
  static const cyan = Color(0xFF52C9DF);
  static const orange = Color(0xFFFF812B);
  static const canvas = Color(0xFFF2F3F5);
  static const muted = Color(0xFF73777B);
  static const palePink = Color(0xFFFFF1F6);
  static const white = Colors.white;
}

abstract final class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.white,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.pink),
  fontFamily: 'Arial',
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w800,
      color: AppColors.ink,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.ink),
  ),
);
