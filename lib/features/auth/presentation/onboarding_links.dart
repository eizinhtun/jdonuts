import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jdonuts/core/theme/tokens.dart';
import 'package:jdonuts/l10n/localization.dart';

class OnboardingSocialLinks extends StatelessWidget {
  const OnboardingSocialLinks({super.key, required this.onPlaceholder});

  final ValueChanged<String> onPlaceholder;

  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l10n.googleLabel,
      context.l10n.appleLabel,
      context.l10n.facebookLabel,
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          label: labels[0],
          onPressed: () => onPlaceholder(labels[0]),
          child: const CustomPaint(
            size: Size(24, 24),
            painter: _GooglePainter(),
          ),
        ),
        const SizedBox(width: 24),
        _SocialButton(
          label: labels[1],
          onPressed: () => onPlaceholder(labels[1]),
          child: const CustomPaint(
            size: Size(27, 29),
            painter: _ApplePainter(),
          ),
        ),
        const SizedBox(width: 24),
        _SocialButton(
          label: labels[2],
          onPressed: () => onPlaceholder(labels[2]),
          child: const Icon(Icons.facebook, size: 27, color: Color(0xFF1877F2)),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.onPressed,
    required this.child,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 56,
    height: 48,
    child: IconButton(
      tooltip: label,
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: child,
    ),
  );
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .39;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];
    for (var index = 0; index < colors.length; index++) {
      final paint = Paint()
        ..color = colors[index]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * .19
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        -math.pi / 4 + index * math.pi / 2,
        math.pi / 2,
        false,
        paint,
      );
    }
    canvas.drawLine(
      center,
      Offset(center.dx + radius, center.dy),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.shortestSide * .19
        ..strokeCap = StrokeCap.butt,
    );
  }

  @override
  bool shouldRepaint(covariant _GooglePainter oldDelegate) => false;
}

class _ApplePainter extends CustomPainter {
  const _ApplePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final body = Path()
      ..addOval(Rect.fromLTWH(2, 8, size.width * .78, size.height * .67))
      ..addOval(
        Rect.fromLTWH(size.width * .34, 8, size.width * .58, size.height * .67),
      );
    final bite = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * .91, size.height * .48),
          radius: size.width * .17,
        ),
      );
    final leaf = Path()
      ..moveTo(size.width * .45, size.height * .25)
      ..cubicTo(
        size.width * .41,
        size.height * .02,
        size.width * .62,
        0,
        size.width * .78,
        size.height * .03,
      )
      ..cubicTo(
        size.width * .76,
        size.height * .18,
        size.width * .61,
        size.height * .28,
        size.width * .45,
        size.height * .25,
      )
      ..close();
    final silhouette = Path.combine(
      PathOperation.union,
      Path.combine(PathOperation.difference, body, bite),
      leaf,
    );
    canvas.drawPath(silhouette, Paint()..color = Colors.black);
  }

  @override
  bool shouldRepaint(covariant _ApplePainter oldDelegate) => false;
}

class OnboardingLegalNotice extends StatefulWidget {
  const OnboardingLegalNotice({
    super.key,
    required this.onTerms,
    required this.onPrivacy,
  });

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  State<OnboardingLegalNotice> createState() => _OnboardingLegalNoticeState();
}

class _OnboardingLegalNoticeState extends State<OnboardingLegalNotice> {
  final _termsRecognizer = TapGestureRecognizer();
  final _privacyRecognizer = TapGestureRecognizer();

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _termsRecognizer.onTap = widget.onTerms;
    _privacyRecognizer.onTap = widget.onPrivacy;
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: Color(0xFF8995A1),
          fontSize: 12,
          height: 1.45,
        ),
        children: [
          TextSpan(text: context.l10n.onboardingLegalPrefix),
          TextSpan(
            text: context.l10n.termsLabel,
            style: const TextStyle(color: AppColors.pink),
            recognizer: _termsRecognizer,
          ),
          TextSpan(text: context.l10n.legalAnd),
          TextSpan(
            text: context.l10n.privacyLabel,
            style: const TextStyle(color: AppColors.pink),
            recognizer: _privacyRecognizer,
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
