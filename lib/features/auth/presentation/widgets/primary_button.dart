import 'package:flutter/material.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/core/theme/tokens.dart';

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool enabled, loading;
  @override
  State<PrimaryButton> createState() => PrimaryButtonState();
}

class PrimaryButtonState extends State<PrimaryButton> {
  bool down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => down = true),
    onTapCancel: () => setState(() => down = false),
    onTapUp: (_) {
      setState(() => down = false);
      if (widget.enabled && !widget.loading) widget.onPressed?.call();
    },
    child: AnimatedScale(
      scale: down ? .97 : 1,
      duration: Motion.duration(context, Motion.quick),
      child: AnimatedContainer(
        duration: Motion.duration(context, Motion.quick),
        height: 52,
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
                    value: MediaQuery.disableAnimationsOf(context) ? .65 : null,
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.label,
                  key: ValueKey(widget.label),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    ),
  );
}
