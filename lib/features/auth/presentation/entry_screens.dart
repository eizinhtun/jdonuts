import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/presentation/animated_entrance.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/features/auth/presentation/auth_draft.dart';
import 'package:jdonuts/features/auth/presentation/widgets/primary_button.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../core/theme/tokens.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.palePink,
    body: LayoutBuilder(
      builder: (context, viewport) => Stack(
        fit: StackFit.expand,
        children: [
          const _WelcomeBackground(),
          const IgnorePointer(child: _WelcomeArtwork()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, safeArea) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: safeArea.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(),
                        AnimatedEntrance(
                          delay: Motion.welcomeTitleDelay,
                          child: SizedBox(
                            width: (viewport.maxWidth - 56).clamp(0, 280),
                            child: Text(
                              context.l10n.welcomeTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily:
                                    Theme.of(context).platform ==
                                        TargetPlatform.iOS
                                    ? 'SF Pro Rounded'
                                    : null,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 1.12,
                                letterSpacing: -.25,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: safeArea.maxHeight * .05),
                        AnimatedEntrance(
                          delay: Motion.welcomeButtonDelay,
                          child: DefaultTextStyle.merge(
                            style: const TextStyle(
                              fontSize: 16,
                              letterSpacing: .5,
                            ),
                            child: PrimaryButton(
                              label: context.l10n.exploreButton,
                              height: 56,
                              onPressed: () => context.go('/home'),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: (safeArea.maxHeight * .055).clamp(20, 44),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _WelcomeBackground extends StatelessWidget {
  const _WelcomeBackground();

  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFBFD), Color(0xFFFFF1F6), Color(0xFFFFF7FA)],
        stops: [0, .72, 1],
      ),
    ),
  );
}

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loggingOut = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.settingsTitle)),
    body: ListTile(
      leading: const Icon(Icons.logout),
      title: Text(context.l10n.logoutLabel),
      trailing: _loggingOut
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: _loggingOut ? null : _logout,
    ),
  );

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    final result = await ref.read(authRepositoryProvider).logout();
    if (!mounted) return;
    result.fold<void>(
      (_) {
        ref.read(authDraftProvider.notifier).state = const AuthDraft();
        ref.read(authStateProvider.notifier).state = false;
        context.go('/onboarding');
      },
      (_) {
        setState(() => _loggingOut = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.genericError)));
      },
    );
  }
}

class _WelcomeArtwork extends StatelessWidget {
  const _WelcomeArtwork();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, viewport) {
      final width = viewport.maxWidth;
      final height = viewport.maxHeight;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -width * .04,
            top: -height * .03,
            width: width * .57,
            height: height * .39,
            child: const AnimatedEntrance(
              child: _WelcomeTile(
                asset: 'coconut.svg',
                label: 'Pink frosted donut',
                color: AppColors.welcomeBlue,
                angle: -.14,
                artScale: 1.15,
              ),
            ),
          ),
          Positioned(
            left: width * .61,
            top: height * .057,
            width: width * .57,
            height: height * .39,
            child: AnimatedEntrance(
              delay: Motion.welcomeTileStagger,
              child: const _WelcomeTile(
                asset: 'strawberry.svg',
                label: 'Chocolate striped donut',
                color: AppColors.welcomeLavender,
                angle: .12,
                fadeAtBottom: true,
              ),
            ),
          ),
          Positioned(
            left: -width * .04,
            top: height * .39,
            width: width * .57,
            height: height * .36,
            child: AnimatedEntrance(
              delay: Motion.welcomeTileStagger * 2,
              child: const _WelcomeTile(
                asset: 'onboarding-hero-donut.png',
                label: 'Pink donut with sprinkles',
                color: AppColors.welcomePeach,
                angle: .1,
                fadeAtBottom: true,
              ),
            ),
          ),
          Positioned(
            left: width * .61,
            top: height * .475,
            width: width * .57,
            height: height * .36,
            child: AnimatedEntrance(
              delay: Motion.welcomeTileStagger * 3,
              child: const _WelcomeTile(
                asset: 'chocolate-donut.png',
                label: 'Dark chocolate donut with pink drizzle',
                color: AppColors.welcomeButter,
                angle: -.14,
                fadeAtBottom: true,
                fadeHeightFactor: .7,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class _WelcomeTile extends StatelessWidget {
  const _WelcomeTile({
    required this.asset,
    required this.label,
    required this.color,
    required this.angle,
    this.fadeAtBottom = false,
    this.fadeHeightFactor = .45,
    this.artScale = 1,
  });

  final String asset;
  final String label;
  final Color color;
  final double angle;
  final bool fadeAtBottom;
  final double fadeHeightFactor;
  final double artScale;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, AppColors.pink, .12)!],
            ),
          ),
        ),
        const CustomPaint(painter: _WelcomeTilePattern()),
        Center(
          child: Transform.scale(
            scale: artScale,
            child: Transform.rotate(
              angle: angle,
              child: FractionallySizedBox(
                widthFactor: .78,
                heightFactor: .68,
                child: SeedImage(assetName: asset, semanticsLabel: label),
              ),
            ),
          ),
        ),
        if (fadeAtBottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fadeHeightFactor,
              widthFactor: 1,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00FFF4F8), Color(0xFFFFF4F8)],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _WelcomeTilePattern extends CustomPainter {
  const _WelcomeTilePattern();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .24)
      ..strokeWidth = size.shortestSide * .035
      ..strokeCap = StrokeCap.round;
    final marks = [
      Offset(.14, .14),
      Offset(.82, .18),
      Offset(.3, .68),
      Offset(.72, .8),
      Offset(.48, .36),
    ];
    for (final mark in marks) {
      canvas.drawCircle(
        Offset(size.width * mark.dx, size.height * mark.dy),
        size.shortestSide * .018,
        paint,
      );
    }
    canvas.drawLine(
      Offset(size.width * .12, size.height * .78),
      Offset(size.width * .38, size.height * .82),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * .78, size.height * .28),
      Offset(size.width * .9, size.height * .55),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _WelcomeTilePattern oldDelegate) => false;
}
