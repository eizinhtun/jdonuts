import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF242424);
  static const pink = Color(0xFFEE5B9A);
  static const cyan = Color(0xFF52C9DF);
  static const orange = Color(0xFFFF812B);
  static const canvas = Color(0xFFF2F3F5);
  static const muted = Color(0xFF73777B);
  static const palePink = Color(0xFFFFF1F6);
  static const avatarPink = Color(0xFFFFD5E2);
  static const welcomeBlue = Color(0xFFB6DDE9);
  static const welcomeLavender = Color(0xFFDBE9F7);
  static const welcomePeach = Color(0xFFFFDCCE);
  static const welcomeButter = Color(0xFFFFCE75);
  static const silver = Color(0xFFBEC4C7);
  static const gold = Color(0xFFF2D565);
  static const platinum = Color(0xFF79D7E8);
  static const donutPink = Color(0xFFEC75A0);
  static const coffeeBrown = Color(0xFFAA694C);
  static const challengeDonutBase = Color(0xFFFFE1EA);
  static const skeletonBase = Color(0xFFE9EAEC);
  static const skeletonSheen = Color(0xFFF5F6F7);
  static const disabled = Color(0xFFB9C0C2);
  static const error = Color(0xFFBA1A1A);
  static const challengeShadow = Color(0x12000000);
  static const tierConnector = Color(0xFFE2E4E5);
  static const challengeDisabled = Color(0xFFE0E3E4);
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
