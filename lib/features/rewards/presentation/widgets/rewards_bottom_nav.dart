import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/core/theme/tokens.dart';
import 'package:jdonuts/l10n/localization.dart';

const _rewardsCanvasColor = Color(0xFFF1F3F3);
const _navigationContentHeight = 72.0;
const _bottomInsetCoverage = .6;
const _referenceFooterHeight = 15.0;

class RewardsBottomNav extends StatelessWidget {
  const RewardsBottomNav({super.key});

  static const _icons = [
    Icons.home_outlined,
    Icons.workspace_premium_outlined,
    Icons.monetization_on_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.homeLabel,
      context.l10n.rewardLabel,
      context.l10n.offersLabel,
      context.l10n.orderLabel,
      context.l10n.profileLabel,
    ];
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final coveredBottomInset = bottomInset * _bottomInsetCoverage;
    final footerHeight = _referenceFooterHeight
        .clamp(0.0, coveredBottomInset)
        .toDouble();
    final dockHeight =
        _navigationContentHeight + coveredBottomInset - footerHeight;
    final totalHeight = dockHeight + footerHeight;
    const itemFlex = [14, 17, 15, 10, 8];
    final showRewardLabel =
        MediaQuery.sizeOf(context).width >= 380 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.1;
    return Container(
      height: totalHeight,
      color: _rewardsCanvasColor,
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: dockHeight,
          child: Container(
            color: AppColors.pink,
            padding: const EdgeInsets.only(left: 22),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.cyan,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: _navigationContentHeight,
                  child: Row(
                    children: [
                      for (var index = 0; index < labels.length; index++)
                        Expanded(
                          flex: itemFlex[index],
                          child: _RewardsNavItem(
                            selected: index == 1,
                            showLabel: index == 1 && showRewardLabel,
                            label: labels[index],
                            icon: _icons[index],
                            onTap: () => _select(context, index),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _select(BuildContext context, int index) {
    if (index == 0) {
      context.go('/home');
    } else if (index == 1) {
      context.go('/rewards');
    } else if (index == 4) {
      context.push('/settings');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
    }
  }
}

class _RewardsNavItem extends StatelessWidget {
  const _RewardsNavItem({
    required this.selected,
    required this.showLabel,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final bool showLabel;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Material(
      color: selected ? AppColors.pink : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          width: selected && showLabel ? 102 : null,
          height: selected && showLabel ? 44 : null,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: selected && showLabel ? 11 : 9,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 21, color: Colors.white),
                  if (showLabel) ...[
                    const SizedBox(width: 3),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final heroEnabled = !MediaQuery.disableAnimationsOf(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: ExcludeSemantics(
        child: Center(
          child: selected
              ? HeroMode(
                  enabled: heroEnabled,
                  child: Hero(tag: Motion.navigationPillHeroTag, child: pill),
                )
              : pill,
        ),
      ),
    );
  }
}
