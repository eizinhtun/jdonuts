import 'package:flutter/material.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/core/theme/tokens.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.enabled = true,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final bool enabled, loading;
  @override
  State<PrimaryButton> createState() => PrimaryButtonState();
}

class PrimaryButtonState extends State<PrimaryButton> {
  bool down = false;
  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final interactive = widget.enabled && !widget.loading;
    return GestureDetector(
      onTapDown: interactive ? (_) => setState(() => down = true) : null,
      onTapCancel: () => setState(() => down = false),
      onTapUp: (_) {
        setState(() => down = false);
        if (widget.enabled && !widget.loading) widget.onPressed?.call();
      },
      child: AnimatedScale(
        scale: down && interactive && !reduceMotion
            ? Motion.buttonPressScale
            : 1,
        duration: Motion.duration(context, Motion.quick),
        curve: Motion.buttonCurve,
        child: AnimatedContainer(
          duration: Motion.duration(context, Motion.quick),
          height: widget.height,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.cyan : AppColors.disabled,
            borderRadius: BorderRadius.circular(28),
          ),
          child: AnimatedSwitcher(
            duration: Motion.duration(context, Motion.quick),
            child: widget.loading
                ? SizedBox(
                    key: ValueKey('loading'),
                    width: 21,
                    height: 21,
                    child: CircularProgressIndicator(
                      value: MediaQuery.disableAnimationsOf(context)
                          ? .65
                          : null,
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Text(
                    widget.label,
                    key: ValueKey(widget.label),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
