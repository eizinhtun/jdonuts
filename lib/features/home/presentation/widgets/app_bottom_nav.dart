import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/l10n/localization.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.selected});
  final int selected;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selected,
    onDestinationSelected: (index) {
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
    },
    destinations: [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        label: context.l10n.homeLabel,
      ),
      NavigationDestination(
        icon: const Icon(Icons.local_offer_outlined),
        label: context.l10n.offersLabel,
      ),
      NavigationDestination(
        icon: const Icon(Icons.stars_outlined),
        label: context.l10n.rewardsLabel,
      ),
      NavigationDestination(
        icon: const Icon(Icons.shopping_bag_outlined),
        label: context.l10n.orderLabel,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        label: context.l10n.profileLabel,
      ),
    ],
  );
}
