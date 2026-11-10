import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/tokens.dart';
import '../../../home/domain/models.dart';

class ChallengeCard extends StatefulWidget {
  const ChallengeCard({super.key, required this.challenge});
  final Challenge challenge;

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _attention;
  bool? _reduceMotion;
  bool? _wasComplete;
  bool _claimed = false;

  bool get _complete =>
      widget.challenge.target > 0 &&
      widget.challenge.progress >= widget.challenge.target;

  @override
  void initState() {
    super.initState();
    _attention = AnimationController(
      vsync: this,
      duration: Motion.rewardAttention,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAttention();
  }

  @override
  void didUpdateWidget(covariant ChallengeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge.progress != widget.challenge.progress ||
        oldWidget.challenge.target != widget.challenge.target) {
      _syncAttention();
    }
  }

  void _syncAttention() {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final complete = _complete && !_claimed;
    if (_reduceMotion == reduceMotion && _wasComplete == complete) return;
    _reduceMotion = reduceMotion;
    _wasComplete = complete;
    if (complete && !reduceMotion) {
      _attention.repeat(reverse: true);
    } else {
      _attention.stop();
      _attention.value = 0;
    }
  }

  @override
  void dispose() {
    _attention.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = widget.challenge;
    final complete = _complete;
    final fraction = challenge.target <= 0
        ? 0.0
        : (challenge.progress / challenge.target).clamp(0.0, 1.0).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.challengeShadow,
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 105,
            child: CustomPaint(
              painter: _ChallengePainter(
                fraction: fraction,
                donut: challenge.kind == 'donut',
              ),
              child: challenge.kind == 'donut'
                  ? null
                  : const Center(
                      child: Icon(
                        Icons.coffee,
                        size: 48,
                        color: AppColors.coffeeBrown,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.challengeCount(
                    challenge.progress,
                    challenge.target,
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    ScaleTransition(
                      scale: Tween<double>(begin: 1, end: 1.035).animate(
                        CurvedAnimation(
                          parent: _attention,
                          curve: Motion.softCurve,
                        ),
                      ),
                      child: FilledButton(
                        onPressed: complete && !_claimed
                            ? () {
                                setState(() => _claimed = true);
                                _syncAttention();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.pointsClaimed(
                                        challenge.points,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          disabledBackgroundColor: AppColors.challengeDisabled,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                        ),
                        child: Text(
                          _claimed
                              ? context.l10n.earnedLabel
                              : context.l10n.earnLabel,
                        ),
                      ),
                    ),
                    Text(context.l10n.earnPoints(challenge.points)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengePainter extends CustomPainter {
  const _ChallengePainter({required this.fraction, required this.donut});
  final double fraction;
  final bool donut;
  @override
  void paint(Canvas canvas, Size size) {
    final progress = fraction.clamp(0.0, 1.0).toDouble();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .38;
    if (donut) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = AppColors.challengeDonutBase,
      );
      for (var i = 0; i < 4; i++) {
        if (progress * 4 > i) {
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            -math.pi / 2 + i * math.pi / 2,
            math.min(math.pi / 2, progress * math.pi * 2 - i * math.pi / 2),
            true,
            Paint()..color = AppColors.donutPink,
          );
        }
      }
      _paintDonutSprinkles(canvas, center, radius, progress);
      for (var i = 1; i < 4; i++) {
        if (progress >= i / 4) {
          final angle = -math.pi / 2 + i * math.pi / 2;
          final start = Offset(
            center.dx + math.cos(angle) * radius * .48,
            center.dy + math.sin(angle) * radius * .48,
          );
          final end = Offset(
            center.dx + math.cos(angle) * radius * .98,
            center.dy + math.sin(angle) * radius * .98,
          );
          canvas.drawLine(
            start,
            end,
            Paint()
              ..color = Colors.white.withValues(alpha: .75)
              ..strokeWidth = 2,
          );
        }
      }
      canvas.drawCircle(center, radius * .45, Paint()..color = Colors.white);
      canvas.drawCircle(
        center,
        radius * .45,
        Paint()
          ..color = AppColors.donutPink.withValues(alpha: .6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawCircle(center, radius, Paint()..color = AppColors.canvas);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..color = AppColors.coffeeBrown
          ..style = PaintingStyle.stroke
          ..strokeWidth = 15
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _paintDonutSprinkles(
    Canvas canvas,
    Offset center,
    double radius,
    double progress,
  ) {
    const colors = [Colors.white, Color(0xFFFFE27A), Color(0xFF6BD6E5)];
    for (var index = 0; index < 16; index++) {
      final fraction = (index + .5) / 16;
      if (fraction > progress) continue;
      final angle = -math.pi / 2 + math.pi * 2 * fraction;
      final position = Offset(
        center.dx + math.cos(angle) * radius * .72,
        center.dy + math.sin(angle) * radius * .72,
      );
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle + (index.isEven ? .7 : -.7));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: 3,
            height: index % 3 == 0 ? 7 : 5,
          ),
          const Radius.circular(3),
        ),
        Paint()..color = colors[index % colors.length],
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ChallengePainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.donut != donut;
}
