import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/presentation/animated_entrance.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/features/auth/presentation/auth_draft.dart';
import 'package:jdonuts/features/auth/presentation/widgets/primary_button.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../core/theme/tokens.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.palePink,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          children: [
            const Spacer(),
            AnimatedEntrance(
              child: SizedBox(
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 10,
                      top: 25,
                      child: _DonutArt(
                        asset: 'coconut.svg',
                        size: 90,
                        angle: -.2,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 0,
                      child: _DonutArt(
                        asset: 'strawberry.svg',
                        size: 110,
                        angle: .18,
                      ),
                    ),
                    Positioned(
                      left: 30,
                      bottom: 0,
                      child: _DonutArt(asset: 'box.svg', size: 100, angle: .2),
                    ),
                    Positioned(
                      right: 25,
                      bottom: 5,
                      child: _DonutArt(
                        asset: 'coffee.svg',
                        size: 94,
                        angle: -.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            AnimatedEntrance(
              delay: const Duration(milliseconds: 90),
              child: Text(
                context.l10n.onboardingHeadline,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            AnimatedEntrance(
              delay: const Duration(milliseconds: 160),
              child: PrimaryButton(
                label: context.l10n.getStarted,
                onPressed: () => context.go('/auth/register/phone'),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            AnimatedEntrance(
              delay: const Duration(milliseconds: 230),
              child: Column(
                children: [
                  TextButton(
                    onPressed: () => context.go('/auth/login/phone'),
                    child: Text(context.l10n.loginLink),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children:
                        [
                              context.l10n.googleLabel,
                              context.l10n.appleLabel,
                              context.l10n.facebookLabel,
                            ]
                            .map(
                              (label) => TextButton(
                                onPressed: () =>
                                    _showPlaceholder(context, label),
                                child: Text(label),
                              ),
                            )
                            .toList(),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children:
                        [context.l10n.termsLabel, context.l10n.privacyLabel]
                            .map(
                              (label) => TextButton(
                                onPressed: () =>
                                    _showPlaceholder(context, label),
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.palePink,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          children: [
            const Spacer(),
            SizedBox(
              height: 330,
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSpace.md,
                mainAxisSpacing: AppSpace.md,
                children: [
                  AnimatedEntrance(
                    child: const _WelcomeTile(
                      asset: 'coconut.svg',
                      color: Color(0xFFB6DDE9),
                      angle: -.14,
                    ),
                  ),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 70),
                    child: const _WelcomeTile(
                      asset: 'strawberry.svg',
                      color: Color(0xFFDBE9F7),
                      angle: .12,
                    ),
                  ),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 140),
                    child: const _WelcomeTile(
                      asset: 'box.svg',
                      color: Color(0xFFFFDCCE),
                      angle: .1,
                    ),
                  ),
                  AnimatedEntrance(
                    delay: const Duration(milliseconds: 210),
                    child: const _WelcomeTile(
                      asset: 'coffee.svg',
                      color: Color(0xFFFFCE75),
                      angle: -.14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            AnimatedEntrance(
              delay: const Duration(milliseconds: 140),
              child: Text(
                context.l10n.welcomeTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Spacer(),
            AnimatedEntrance(
              delay: const Duration(milliseconds: 220),
              child: PrimaryButton(
                label: context.l10n.exploreButton,
                onPressed: () => context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.settingsTitle)),
    body: ListTile(
      leading: const Icon(Icons.logout),
      title: Text(context.l10n.logoutLabel),
      onTap: () async {
        await ref.read(authRepositoryProvider).logout();
        ref.read(authDraftProvider.notifier).state = const AuthDraft();
        ref.read(authStateProvider.notifier).state = false;
        if (context.mounted) context.go('/onboarding');
      },
    ),
  );
}

class _WelcomeTile extends StatelessWidget {
  const _WelcomeTile({
    required this.asset,
    required this.color,
    required this.angle,
  });

  final String asset;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: Transform.rotate(
        angle: angle,
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: SeedImage(assetName: asset),
        ),
      ),
    ),
  );
}

class _DonutArt extends StatelessWidget {
  const _DonutArt({
    required this.asset,
    required this.size,
    required this.angle,
  });

  final String asset;
  final double size;
  final double angle;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: SizedBox(
      width: size,
      height: size,
      child: SeedImage(assetName: asset),
    ),
  );
}

void _showPlaceholder(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(context.l10n.socialPlaceholder(feature))),
  );
}
