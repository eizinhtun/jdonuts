import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/tokens.dart';

import '../../../../core/motion/motion.dart';

class RewardTab extends StatelessWidget {
  const RewardTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: selected
              ? null
              : BoxDecoration(
                  color: AppColors.canvas,
                  border: Border.all(color: AppColors.white, width: 2),
                  borderRadius: BorderRadius.circular(24),
                ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: Motion.duration(context, Motion.quick),
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.muted,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                fontFamily: Theme.of(context).platform == TargetPlatform.iOS
                    ? 'SF Pro Rounded'
                    : null,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
