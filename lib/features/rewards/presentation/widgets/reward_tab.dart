import 'package:flutter/material.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/tokens.dart';

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
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: Motion.duration(context, Motion.quick),
          style: TextStyle(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    ),
  );
}
