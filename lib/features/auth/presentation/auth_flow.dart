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

  bool get _isRegistration => widget.mode == 'register';
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
          TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 10, end: -7), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -7, end: 5), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 5, end: 0), weight: 1),
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
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
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
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color ?? Colors.transparent),
  );
}

class _AuthFlowState extends _AuthFlowHost
    with _AuthFlowActions, _AuthFlowInputs, _AuthFlowForms, _AuthFlowLayout {
  @override
  Widget build(BuildContext context) => _buildScreen(context);
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.progress, required this.done});

  final double progress;
  final bool done;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween<double>(end: progress),
    duration: Motion.duration(context, Motion.standard),
    curve: Motion.curve,
    builder: (context, animatedProgress, _) => SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: animatedProgress,
            strokeWidth: 3,
            backgroundColor: AppColors.canvas,
            color: AppColors.pink,
          ),
          AnimatedSwitcher(
            duration: Motion.duration(context, Motion.quick),
            child: Icon(
              done ? Icons.check : Icons.circle,
              key: ValueKey(done),
              size: done ? 18 : 6,
              color: AppColors.pink,
            ),
          ),
        ],
      ),
    ),
  );
}
