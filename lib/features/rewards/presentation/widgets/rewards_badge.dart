import 'package:flutter/material.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/tokens.dart';

class RewardsBadge extends StatelessWidget {
  const RewardsBadge({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: CurvedAnimation(parent: animation, curve: Motion.badgePopCurve),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.rewardsBadge,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 11,
            backgroundColor: Colors.white,
            child: Text(
              '3',
              style: TextStyle(color: AppColors.ink, fontSize: 12),
            ),
          ),
        ],
      ),
    ),
  );
}
