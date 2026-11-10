import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/core/presentation/seed_image.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../../core/theme/tokens.dart';
import '../../../home/domain/models.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.member});
  final Member member;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.avatarPink,
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: SeedImage(
                assetName: member.image,
                semanticsLabel: member.name,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name, style: Theme.of(context).textTheme.titleMedium),
              Text(
                context.l10n.memberTierLabel(member.tier),
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.homeGoldProgress(member.pointsToGold),
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Badge(
            label: Text(context.l10n.notificationCount(member.notifications)),
            child: const Icon(Icons.notifications_none),
          ),
        ),
        IconButton(
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    ),
  );
}
