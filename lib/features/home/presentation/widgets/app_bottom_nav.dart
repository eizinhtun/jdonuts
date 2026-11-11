import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/core/theme/tokens.dart';
import 'package:jdonuts/l10n/localization.dart';

const _homeNavigationContentHeight = 72.0;
const _homeNavigationTopSpacing = 8.0;
const _homeNavigationSideInset = 16.0;
const _homePinkBackingHeight = _homeNavigationContentHeight / 2;

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selected,
    this.homeStyle = false,
  });

  final int selected;
  final bool homeStyle;

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    if (homeStyle) {
      final navItemWidth =
          (MediaQuery.sizeOf(context).width -
              2 * _homeNavigationSideInset -
              16) /
          items.length;
      final compact =
          navItemWidth < 68 || MediaQuery.textScalerOf(context).scale(1) > 1.2;
      final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
      final panelHeight = _homeNavigationContentHeight + bottomInset;
      final pinkBackingHeight = _homePinkBackingHeight + bottomInset;
      return SizedBox(
        height: _homeNavigationTopSpacing + panelHeight,
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: AppColors.rewardsCanvas),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: pinkBackingHeight,
              child: const ColoredBox(color: AppColors.pink),
            ),
            Positioned(
              left: _homeNavigationSideInset,
              right: _homeNavigationSideInset,
              bottom: 0,
              height: panelHeight,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.cyan,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    height: _homeNavigationContentHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          for (var index = 0; index < items.length; index++)
                            Expanded(
                              child: _HomeNavigationItem(
                                selected: selected == index,
                                showLabel: selected == index && !compact,
                                icon: items[index].icon,
                                label: items[index].label,
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
          ],
        ),
      );
    }

    return NavigationBar(
      selectedIndex: selected,
      onDestinationSelected: (index) => _select(context, index),
      destinations: [
        for (final item in items)
          NavigationDestination(icon: Icon(item.icon), label: item.label),
      ],
    );
  }

  List<_NavigationItemData> _items(BuildContext context) => [
    _NavigationItemData(Icons.home_outlined, context.l10n.homeLabel),
    _NavigationItemData(
      Icons.workspace_premium_outlined,
      context.l10n.rewardLabel,
    ),
    _NavigationItemData(
      Icons.monetization_on_outlined,
      context.l10n.offersLabel,
    ),
    _NavigationItemData(
      Icons.account_balance_wallet_outlined,
      context.l10n.orderLabel,
    ),
    _NavigationItemData(Icons.settings_outlined, context.l10n.profileLabel),
  ];

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

class _NavigationItemData {
  const _NavigationItemData(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _HomeNavigationItem extends StatelessWidget {
  const _HomeNavigationItem({
    required this.selected,
    required this.showLabel,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final bool showLabel;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Material(
      color: selected ? AppColors.pink : AppColors.transparent,
      shape: RoundedRectangleBorder(
        side: selected
            ? const BorderSide(color: AppColors.white, width: 1.5)
            : BorderSide.none,
        borderRadius: BorderRadius.circular(24),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: selected && showLabel
                ? 7
                : selected
                ? 8
                : 10,
            vertical: 9,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: AppColors.white),
              if (showLabel) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
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
