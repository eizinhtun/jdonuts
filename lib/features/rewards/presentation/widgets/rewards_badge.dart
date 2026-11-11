import 'package:flutter/material.dart';
import 'package:jdonuts/l10n/localization.dart';
import 'package:jdonuts/core/theme/tokens.dart';

import '../../../../core/motion/motion.dart';

class RewardsBadge extends StatelessWidget {
  const RewardsBadge({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: CurvedAnimation(parent: animation, curve: Motion.badgePopCurve),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          const CircleAvatar(
            radius: 9,
            backgroundColor: AppColors.white,
            child: Text(
              '3',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
