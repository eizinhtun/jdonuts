import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/core/theme/tokens.dart';
import 'package:jdonuts/l10n/localization.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.selected,
    this.homeStyle = false,
  });

  final int selected;
  final bool homeStyle;

  static const _homeIcons = [
    Icons.home_outlined,
    Icons.workspace_premium_outlined,
    Icons.monetization_on_outlined,
    Icons.shopping_bag_outlined,
    Icons.settings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    if (homeStyle) {
      final compact =
          MediaQuery.sizeOf(context).width < 380 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.2;
      return Container(
        color: AppColors.cyan,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  for (var index = 0; index < items.length; index++)
                    Expanded(
                      child: _HomeNavigationItem(
                        selected: selected == index,
                        showLabel: selected == index && !compact,
                        icon: _homeIcons[index],
                        label: items[index].label,
                        onTap: () => _select(context, index),
                      ),
                    ),
                ],
              ),
            ),
          ),
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
    _NavigationItemData(Icons.local_offer_outlined, context.l10n.offersLabel),
    _NavigationItemData(Icons.stars_outlined, context.l10n.rewardsLabel),
    _NavigationItemData(Icons.shopping_bag_outlined, context.l10n.orderLabel),
    _NavigationItemData(Icons.person_outline, context.l10n.profileLabel),
  ];

  void _select(BuildContext context, int index) {
    if (index == 0) {
      context.go('/home');
    } else if (index == 2) {
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
      color: selected ? AppColors.pink : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 8 : 10,
            vertical: 9,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: Colors.white),
              if (showLabel) ...[
                const SizedBox(width: 4),
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
