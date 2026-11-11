import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/presentation/animated_entrance.dart';
import 'package:jdonuts/core/theme/tokens.dart';
import 'package:jdonuts/features/auth/presentation/onboarding_artwork.dart';
import 'package:jdonuts/features/auth/presentation/onboarding_links.dart';
import 'package:jdonuts/features/auth/presentation/widgets/primary_button.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../core/motion/motion.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, screen) => Stack(
        fit: StackFit.expand,
        children: [
          const _Background(),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screen.maxHeight * .53,
            child: const OnboardingArtwork(),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, content) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final topSpaceFactor =
                    content.maxHeight < 700 || textScale > 1.15 ? .42 : .54;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: content.maxHeight - 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: content.maxHeight * topSpaceFactor),
                        AnimatedEntrance(
                          delay: Motion.onboardingHeadlineDelay,
                          child: Align(
                            child: SizedBox(
                              width: content.maxWidth.clamp(0, 300),
                              child: Text(
                                context.l10n.onboardingHeadline,
                                style: TextStyle(
                                  fontFamily:
                                      Theme.of(context).platform ==
                                          TargetPlatform.iOS
                                      ? 'SF Pro Rounded'
                                      : null,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
                                  height: 1.08,
                                  letterSpacing: -.35,
                                  color: AppColors.ink,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),
                        AnimatedEntrance(
                          delay: Motion.onboardingButtonDelay,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: DefaultTextStyle.merge(
                              style: const TextStyle(
                                fontSize: 14,
                                letterSpacing: .8,
                              ),
                              child: PrimaryButton(
                                label: context.l10n.getStarted,
                                height: 56,
                                onPressed: () =>
                                    context.go('/auth/register/phone'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AnimatedEntrance(
                          delay: Motion.onboardingLinksDelay,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => context.go('/auth/login/phone'),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: context.l10n.accountPrompt,
                                    style: const TextStyle(
                                      color: Color(0xFF53565C),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const TextSpan(text: ' '),
                                  TextSpan(
                                    text: context.l10n.loginAction,
                                    style: const TextStyle(
                                      color: AppColors.pink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        AnimatedEntrance(
                          delay: Motion.onboardingLinksDelay,
                          child: OnboardingSocialLinks(
                            onPlaceholder: (label) =>
                                _showPlaceholder(context, label),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedEntrance(
                          delay: Motion.onboardingLinksDelay,
                          child: OnboardingLegalNotice(
                            onTerms: () => _showPlaceholder(
                              context,
                              context.l10n.termsLabel,
                            ),
                            onPrivacy: () => _showPlaceholder(
                              context,
                              context.l10n.privacyLabel,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFCFD), Color(0xFFFFF7FA), Color(0xFFFCEBF2)],
        stops: [0, .55, 1],
      ),
    ),
  );
}

void _showPlaceholder(BuildContext context, String feature) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(context.l10n.socialPlaceholder(feature))),
  );
}
