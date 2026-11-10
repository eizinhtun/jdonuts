import 'package:flutter/material.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/tokens.dart';

class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({super.key});

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;
  bool? _reduceMotion;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: Motion.skeletonShimmer,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _shimmer.stop();
      _shimmer.value = .5;
    } else {
      _shimmer.repeat();
    }
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _shimmer,
    child: _placeholderLayout(),
    builder: (context, child) {
      final start = -1.5 + _shimmer.value * 3;
      return ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(start, 0),
          end: Alignment(start + 1.2, 0),
          colors: const [
            AppColors.skeletonBase,
            AppColors.skeletonSheen,
            AppColors.skeletonBase,
          ],
        ).createShader(bounds),
        child: child,
      );
    },
  );

  Widget _placeholderLayout() => ListView(
    padding: const EdgeInsets.all(AppSpace.md),
    children: [
      _block(height: 58),
      const SizedBox(height: AppSpace.md),
      _block(height: 150),
      const SizedBox(height: AppSpace.lg),
      for (var section = 0; section < 3; section++) ...[
        _block(height: 22, width: 155),
        const SizedBox(height: AppSpace.sm),
        Row(
          children: [
            Expanded(child: _block(height: 150)),
            const SizedBox(width: AppSpace.sm),
            Expanded(child: _block(height: 150)),
          ],
        ),
        const SizedBox(height: AppSpace.lg),
      ],
    ],
  );

  Widget _block({required double height, double? width}) => Container(
    width: width,
    height: height,
    decoration: const BoxDecoration(
      color: AppColors.skeletonBase,
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  );
}
