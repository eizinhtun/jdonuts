import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/app/providers.dart';
import 'package:jdonuts/core/result/result.dart';
import 'package:jdonuts/core/motion/motion.dart';
import 'package:jdonuts/core/theme/tokens.dart';
import 'package:jdonuts/features/auth/domain/auth_repository.dart';
import 'package:jdonuts/features/auth/presentation/auth_draft.dart';
import 'package:jdonuts/features/auth/presentation/onboarding_links.dart';
import 'package:jdonuts/features/auth/presentation/widgets/primary_button.dart';
import 'package:jdonuts/l10n/localization.dart';

import '../domain/otp_policy.dart';
import '../domain/validators.dart';

part 'auth_flow_actions.dart';
part 'auth_flow_layout.dart';
part 'auth_flow_forms.dart';
part 'auth_flow_inputs.dart';

const _otpDigits = 6;

class AuthFlow extends ConsumerStatefulWidget {
  const AuthFlow({super.key, required this.mode, required this.step});

  final String mode;
  final String step;

  @override
  ConsumerState<AuthFlow> createState() => _AuthFlowState();
}

abstract class _AuthFlowHost extends ConsumerState<AuthFlow>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _phone;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _birthMonth;
  late final TextEditingController _birthDay;
  late final TextEditingController _birthYear;
  late final List<TextEditingController> _otpFields;
  final _otpFocus = List.generate(_otpDigits, (_) => FocusNode());
  final _phoneFocus = FocusNode();
  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;
  Timer? _countdownTimer;

  int _remainingSeconds = 0;
  bool _loading = false;
  bool _phoneBlurred = false;
  bool _nameSubmitted = false;
  bool _dateSubmitted = false;
  String? _error;
  DateTime? _birthDate;
  double _stepDirection = 1;

  bool get _isRegistration => widget.mode == 'register';
  bool get _useReferenceAuthLayout =>
      _isRegistration &&
      (widget.step == 'phone' ||
          widget.step == 'otp' ||
          widget.step == 'name' ||
          widget.step == 'dob');
  String get _phoneValue => normalizePhone(_phone.text);
  String get _otpValue => _otpFields.map((field) => field.text).join();

  @override
  void initState() {
    super.initState();
    final draft = ref.read(authDraftProvider);
    _phone = TextEditingController(text: draft.phone);
    _firstName = TextEditingController(text: draft.firstName);
    _lastName = TextEditingController(text: draft.lastName);
    final storedDate = draft.birthDate;
    _birthMonth = TextEditingController(
      text: draft.birthMonth.isNotEmpty
          ? draft.birthMonth
          : storedDate?.month.toString() ?? '',
    );
    _birthDay = TextEditingController(
      text: draft.birthDay.isNotEmpty
          ? draft.birthDay
          : storedDate?.day.toString() ?? '',
    );
    _birthYear = TextEditingController(
      text: draft.birthYear.isNotEmpty
          ? draft.birthYear
          : storedDate?.year.toString() ?? '',
    );
    _birthDate = parseBirthDate(
      _birthMonth.text,
      _birthDay.text,
      _birthYear.text,
    );
    _otpFields = List.generate(_otpDigits, (index) {
      final digit = index < draft.otp.length ? draft.otp[index] : '';
      return TextEditingController(text: digit);
    });
    _phoneFocus.addListener(_onPhoneFocusChanged);
    _shakeController = AnimationController(vsync: this, duration: Motion.shake);
    _shakeOffset =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(begin: 0, end: -Motion.otpShakeFullDistance),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: -Motion.otpShakeFullDistance,
              end: Motion.otpShakeFullDistance,
            ),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: Motion.otpShakeFullDistance,
              end: -Motion.otpShakeMediumDistance,
            ),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: -Motion.otpShakeMediumDistance,
              end: Motion.otpShakeSmallDistance,
            ),
            weight: 2,
          ),
          TweenSequenceItem(
            tween: Tween(begin: Motion.otpShakeSmallDistance, end: 0),
            weight: 1,
          ),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Motion.softCurve),
        );
    if (widget.step == 'otp') _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _shakeController.dispose();
    _phone.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _birthMonth.dispose();
    _birthDay.dispose();
    _birthYear.dispose();
    _phoneFocus
      ..removeListener(_onPhoneFocusChanged)
      ..dispose();
    for (final controller in _otpFields) {
      controller.dispose();
    }
    for (final focus in _otpFocus) {
      focus.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AuthFlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step == widget.step) return;
    _stepDirection = _stepOrder(widget.step) >= _stepOrder(oldWidget.step)
        ? 1
        : -1;
    if (widget.step == 'otp') {
      _startCountdown();
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
    }
  }

  void _onPhoneFocusChanged() {
    if (!_phoneFocus.hasFocus && mounted) {
      setState(() => _phoneBlurred = true);
    }
  }

  void _saveDraft(AuthDraft draft) {
    ref.read(authDraftProvider.notifier).state = draft;
  }

  void _onPhoneChanged(String value) {
    final draft = ref.read(authDraftProvider);
    final changedNumber = normalizePhone(draft.phone) != normalizePhone(value);
    _saveDraft(
      draft.copyWith(
        phone: value,
        otp: changedNumber ? '' : draft.otp,
        otpFailures: changedNumber ? 0 : draft.otpFailures,
        otpVerified: changedNumber ? false : draft.otpVerified,
        clearResendDeadline: changedNumber,
      ),
    );
    setState(() => _error = null);
  }

  void _onOtpChanged() {
    final draft = ref.read(authDraftProvider);
    _saveDraft(draft.copyWith(otp: _otpValue));
    setState(() => _error = null);
  }

  int _secondsUntilResend() => secondsUntilOtpResend(
    ref.read(authDraftProvider).resendDeadline,
    ref.read(clockProvider)(),
  );

  void _startCountdown() {
    _countdownTimer?.cancel();
    final draft = ref.read(authDraftProvider);
    if (draft.resendDeadline == null) {
      final deadline = otpResendDeadline(ref.read(clockProvider)());
      _saveDraft(draft.copyWith(resendDeadline: deadline));
    }
    _updateCountdown();
    _countdownTimer = Timer.periodic(Motion.otpCountdownTick, (_) {
      if (mounted) _updateCountdown();
    });
  }

  void _updateCountdown() {
    final seconds = _secondsUntilResend();
    if (seconds != _remainingSeconds) {
      setState(() => _remainingSeconds = seconds);
    }
  }

  OutlineInputBorder _inputBorder({Color? color}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(
      _useReferenceAuthLayout && widget.step != 'otp' ? 10 : 8,
    ),
    borderSide: BorderSide(color: color ?? AppColors.transparent),
  );

  int _stepOrder(String step) => switch (step) {
    'phone' => 0,
    'otp' => 1,
    'name' => 2,
    'dob' => 3,
    _ => 0,
  };
}

class _AuthFlowState extends _AuthFlowHost
    with _AuthFlowActions, _AuthFlowInputs, _AuthFlowForms, _AuthFlowLayout {
  @override
  Widget build(BuildContext context) => _buildScreen(context);
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({
    required this.progress,
    required this.done,
    this.compact = false,
  });

  final double progress;
  final bool done;
  final bool compact;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: progress),
    duration: Motion.duration(context, Motion.authProgressMorph),
    curve: Motion.curve,
    builder: (context, animatedProgress, _) {
      final checkProgress = done
          ? ((animatedProgress - Motion.authProgressCheckReveal) /
                    (1 - Motion.authProgressCheckReveal))
                .clamp(0.0, 1.0)
          : 0.0;
      final size = compact ? 36.0 : 44.0;
      return SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: compact ? 1 - checkProgress : 1,
              child: CircularProgressIndicator(
                value: animatedProgress,
                strokeWidth: compact ? 6 : 3,
                strokeCap: compact ? StrokeCap.round : StrokeCap.butt,
                backgroundColor: compact ? AppColors.cyan : AppColors.canvas,
                color: AppColors.pink,
              ),
            ),
            if (compact)
              Opacity(
                opacity: checkProgress,
                child: Transform.scale(
                  scale: checkProgress,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: const BoxDecoration(
                      color: AppColors.pink,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              )
            else
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 1 - checkProgress,
                    child: const Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.pink,
                    ),
                  ),
                  Opacity(
                    opacity: checkProgress,
                    child: Transform.scale(
                      scale: checkProgress,
                      child: const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.pink,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}
