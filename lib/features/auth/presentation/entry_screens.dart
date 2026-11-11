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
    body: _EntryContent(
      child: Column(
        children: [
          const SizedBox(height: 0),
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
                    color: AppColors.welcomeBlue,
                    angle: -.14,
                  ),
                ),
                AnimatedEntrance(
                  delay: Motion.welcomeTileStagger,
                  child: const _WelcomeTile(
                    asset: 'strawberry.svg',
                    color: AppColors.welcomeLavender,
                    angle: .12,
                  ),
                ),
                AnimatedEntrance(
                  delay: Motion.welcomeTileStagger * 2,
                  child: const _WelcomeTile(
                    asset: 'box.svg',
                    color: AppColors.welcomePeach,
                    angle: .1,
                  ),
                ),
                AnimatedEntrance(
                  delay: Motion.welcomeTileStagger * 3,
                  child: const _WelcomeTile(
                    asset: 'coffee.svg',
                    color: AppColors.welcomeButter,
                    angle: -.14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: (MediaQuery.sizeOf(context).height - 700).clamp(0.0, 72.0),
          ),
          AnimatedEntrance(
            delay: Motion.welcomeTitleDelay,
            child: Text(
              context.l10n.welcomeTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Spacer(),
          AnimatedEntrance(
            delay: Motion.welcomeButtonDelay,
            child: PrimaryButton(
              label: context.l10n.exploreButton,
              onPressed: () => context.go('/home'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _EntryContent extends StatelessWidget {
  const _EntryContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: (constraints.maxHeight - AppSpace.lg * 2).clamp(
              0.0,
              double.infinity,
            ),
          ),
          child: IntrinsicHeight(child: child),
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
