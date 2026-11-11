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
  static const black = Colors.black;
  static const transparent = Colors.transparent;
  static const fieldHint = Color(0xFF8995A1);
  static const onboardingBottom = Color(0xFFFFF7FA);
  static const memberHeader = Color(0xFFFFEEE0);
  static const donutTilePeach = Color(0xFFF9DFD2);
  static const donutTilePink = Color(0xFFF5B1C9);
  static const rewardsCanvas = Color(0xFFF1F3F3);
  static const googleBlue = Color(0xFF4285F4);
  static const onboardingMist = Color(0xFFFFFCFD);
  static const onboardingBlush = Color(0xFFFFFBFD);
  static const onboardingSoft = Color(0xFFFFFAFC);
  static const welcomeBackground = Color(0xFFFFF4F8);
  static const authGradientStart = Color(0xFFFFEFF5);
  static const memberCard = Color(0xFFFFDDBF);
  static const onboardingSun = Color(0xFFFFD58B);
  static const pointsGlow = Color(0xFFFFD4E1);
  static const pointsHighlight = Color(0xFFFFC5D8);
  static const pointsHighlightSoft = Color(0xFFFFB4CC);
  static const authBackgroundMid = Color(0xFFFCEBF2);
  static const googleYellow = Color(0xFFFBBC05);
  static const onboardingTile = Color(0xFFF8D5E2);
  static const ringTrack = Color(0xFFF0F1F2);
  static const googleRed = Color(0xFFEA4335);
  static const welcomeCircleBlue = Color(0xFFC7E0F0);
  static const welcomeCircleLavender = Color(0xFFBFD8EF);
  static const onboardingBlue = Color(0xFFAECFED);
  static const authProgressTrack = Color(0xFF9DDEF1);
  static const memberPlaceholder = Color(0xFF9D8C7D);
  static const inputSlate = Color(0xFF8996A3);
  static const helpGreen = Color(0xFF83BF49);
  static const bodyMuted = Color(0xFF7D8286);
  static const headerMuted = Color(0xFF74777A);
  static const memberMuted = Color(0xFF74716F);
  static const memberLabel = Color(0xFF6D6965);
  static const bannerPurple = Color(0xFF6258A7);
  static const labelSlate = Color(0xFF53565C);
  static const onboardingCyan = Color(0xFF48CDE2);
  static const bannerCyan = Color(0xFF39BED7);
  static const googleGreen = Color(0xFF34A853);
  static const productInk = Color(0xFF303A43);
  static const facebookBlue = Color(0xFF1877F2);
  static const memberShadow = Color(0x12A85A37);
  static const softShadow = Color(0x08000000);
  static const onboardingClear = Color(0x00FFF7FA);
  static const welcomeClear = Color(0x00FFF4F8);
}

abstract final class AppSpace {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const tight = 5.0;
  static const compact = 6.0;
  static const sm = 8.0;
  static const cardGap = 10.0;
  static const smPlus = 12.0;
  static const md = 16.0;
  static const sectionHeadingGap = 9.0;
  static const sectionGap = 18.0;
  static const mdPlus = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

abstract final class AppTypography {
  static const pageHeading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );
  static const brandHeading = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );
  static const sectionHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );
  static const cardHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );
  static const body = TextStyle(fontSize: 14, color: AppColors.ink);
  static const bodyLarge = TextStyle(fontSize: 15, color: AppColors.ink);
  static const caption = TextStyle(fontSize: 12, color: AppColors.muted);
  static const memberName = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    height: 1.1,
    color: AppColors.ink,
  );
  static const memberTier = TextStyle(
    fontSize: 11,
    height: 1.1,
    color: AppColors.memberLabel,
  );
  static const badgeLabel = TextStyle(
    color: AppColors.white,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );
  static const productLabel = TextStyle(
    color: AppColors.ink,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.18,
  );
  static const challengeHeading = TextStyle(
    fontSize: 15,
    height: 1.12,
    fontWeight: FontWeight.w800,
  );
  static const earnButtonLabel = TextStyle(
    fontWeight: FontWeight.w800,
    letterSpacing: .5,
    fontSize: 14,
  );
  static const navigationLabel = TextStyle(
    color: AppColors.white,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );
}

ThemeData buildAppTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.white,
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.pink),
  textTheme: const TextTheme(
    headlineMedium: AppTypography.pageHeading,
    titleLarge: AppTypography.brandHeading,
    titleMedium: AppTypography.cardHeading,
    bodyMedium: AppTypography.body,
  ),
);
