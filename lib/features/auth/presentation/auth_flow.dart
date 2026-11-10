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

const _otpDigits = 6;

class AuthFlow extends ConsumerStatefulWidget {
  const AuthFlow({super.key, required this.mode, required this.step});

  final String mode;
  final String step;

  @override
  ConsumerState<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends ConsumerState<AuthFlow>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _phone;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
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
    _birthDate = draft.birthDate;
    _otpFields = List.generate(_otpDigits, (index) {
      final digit = index < draft.otp.length ? draft.otp[index] : '';
      return TextEditingController(text: digit);
    });
    _phoneFocus.addListener(_onPhoneFocusChanged);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _shakeOffset = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 10, end: -7), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -7, end: 5), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 5, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
    if (widget.step == 'otp') _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _shakeController.dispose();
    _phone.dispose();
    _firstName.dispose();
    _lastName.dispose();
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

  Future<void> _continueFromPhone() async {
    if (_loading || validatePhone(_phone.text) != null) return;
    final canonical = '95$_phoneValue';
    final draft = ref.read(authDraftProvider);
    setState(() {
      _loading = true;
      _error = null;
    });

    final repository = ref.read(authRepositoryProvider);
    if (!_isRegistration && !await repository.isRegistered(canonical)) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.l10n.unknownNumber;
      });
      return;
    }
    if (!mounted) return;
    final hasActiveCode =
        normalizePhone(draft.phone) == _phoneValue &&
        draft.resendDeadline != null &&
        _secondsUntilResend() > 0;
    if (hasActiveCode) {
      setState(() {
        _loading = false;
        _remainingSeconds = _secondsUntilResend();
      });
      context.go('/auth/${widget.mode}/otp');
      return;
    }
    final request = await repository.requestOtp(canonical);
    if (!mounted) return;
    final failure = _failureFrom(request);
    if (failure != null) {
      setState(() {
        _loading = false;
        _error = failure;
      });
      return;
    }

    final currentDraft = ref.read(authDraftProvider);
    _saveDraft(
      currentDraft.copyWith(
        phone: _phone.text,
        otp: '',
        otpFailures: 0,
        otpVerified: false,
        resendDeadline: otpResendDeadline(ref.read(clockProvider)()),
      ),
    );
    setState(() {
      _loading = false;
      _remainingSeconds = otpResendWindow.inSeconds;
    });
    context.go('/auth/${widget.mode}/otp');
  }

  Future<void> _resendCode() async {
    if (_loading || _secondsUntilResend() > 0) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await ref
        .read(authRepositoryProvider)
        .requestOtp('95$_phoneValue');
    if (!mounted) return;
    final failure = _failureFrom(result);
    if (failure != null) {
      setState(() {
        _loading = false;
        _error = failure;
      });
      return;
    }
    final draft = ref.read(authDraftProvider);
    _saveDraft(
      draft.copyWith(
        otp: '',
        otpFailures: 0,
        otpVerified: false,
        resendDeadline: otpResendDeadline(ref.read(clockProvider)()),
      ),
    );
    for (final field in _otpFields) {
      field.clear();
    }
    setState(() {
      _loading = false;
      _remainingSeconds = otpResendWindow.inSeconds;
    });
    _otpFocus.first.requestFocus();
  }

  Future<void> _verifyCode() async {
    if (_loading ||
        ref.read(authDraftProvider).isOtpLocked ||
        validateOtp(_otpValue) != null) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final phone = '95$_phoneValue';
    final result = _isRegistration
        ? await ref.read(authRepositoryProvider).verifyOtp(phone, _otpValue)
        : await ref.read(authRepositoryProvider).login(phone, _otpValue);
    if (!mounted) return;
    setState(() => _loading = false);

    result.fold<void>(
      (_) {
        if (_isRegistration) {
          final draft = ref.read(authDraftProvider);
          _saveDraft(draft.copyWith(otpVerified: true));
          context.go('/auth/register/name');
        } else {
          ref.read(authStateProvider.notifier).state = true;
          context.go('/home');
        }
      },
      (failure) {
        if (failure is AuthFailure &&
            failure.code == AuthFailureCode.unknownNumber) {
          setState(() => _error = context.l10n.unknownNumber);
          return;
        }
        _recordWrongCode();
      },
    );
  }

  void _recordWrongCode() {
    final draft = ref.read(authDraftProvider);
    final failures = draft.otpFailures + 1;
    _saveDraft(
      draft.copyWith(otp: '', otpFailures: failures, otpVerified: false),
    );
    for (final field in _otpFields) {
      field.clear();
    }
    setState(() {
      _error = failures >= otpAttemptLimit
          ? context.l10n.otpLocked
          : context.l10n.otpIncorrect;
    });
    if (!MediaQuery.disableAnimationsOf(context)) {
      _shakeController.forward(from: 0);
    }
    _otpFocus.first.requestFocus();
  }

  Future<void> _continueFromName() async {
    if (_loading) return;
    final firstError = validateFirstName(_firstName.text);
    final lastError = validateLastName(_lastName.text);
    if (firstError != null || lastError != null) {
      setState(() => _nameSubmitted = true);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final phone = '95$_phoneValue';
    final profile = AuthUser(
      phone: phone,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      birthDate: null,
    );
    final result = await ref
        .read(authRepositoryProvider)
        .saveRegistrationProfile(profile);
    if (!mounted) return;
    final failure = _failureFrom(result);
    if (failure != null) {
      setState(() {
        _loading = false;
        _error = failure;
      });
      return;
    }
    final draft = ref.read(authDraftProvider);
    _saveDraft(
      draft.copyWith(firstName: _firstName.text, lastName: _lastName.text),
    );
    setState(() => _loading = false);
    context.go('/auth/register/dob');
  }

  Future<void> _continueFromBirthDate() async {
    final validation = validateBirthDate(_birthDate);
    if (validation != null) {
      setState(() => _dateSubmitted = true);
      return;
    }
    if (_loading) return;
    final draft = ref.read(authDraftProvider);
    if (!draft.otpVerified) {
      setState(() => _error = context.l10n.otpInvalid);
      context.go('/auth/register/phone');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final user = AuthUser(
      phone: '95$_phoneValue',
      firstName: _firstName.text.trim().isEmpty
          ? draft.firstName.trim()
          : _firstName.text.trim(),
      lastName: _lastName.text.trim().isEmpty
          ? draft.lastName.trim()
          : _lastName.text.trim(),
      birthDate: _birthDate,
    );
    final result = await ref.read(authRepositoryProvider).register(user);
    if (!mounted) return;
    result.fold<void>(
      (_) {
        _saveDraft(
          ref
              .read(authDraftProvider)
              .copyWith(birthDate: _birthDate, otpVerified: false),
        );
        context.go('/welcome');
        ref.read(authStateProvider.notifier).state = true;
      },
      (failure) => setState(() {
        _loading = false;
        _error = _failureMessage(failure);
      }),
    );
  }

  String? _failureFrom(Result<bool> result) =>
      result.fold<String?>((_) => null, _failureMessage);

  String _failureMessage(Failure failure) {
    if (failure is AuthFailure) {
      return switch (failure.code) {
        AuthFailureCode.incorrectCode => context.l10n.otpIncorrect,
        AuthFailureCode.unknownNumber => context.l10n.unknownNumber,
        AuthFailureCode.unverifiedNumber => context.l10n.otpInvalid,
        AuthFailureCode.registrationIncomplete => context.l10n.invalidName,
      };
    }
    return context.l10n.genericError;
  }

  String? _validationMessage(AuthValidationError? error) => switch (error) {
    null => null,
    AuthValidationError.invalidPhone => context.l10n.phoneInvalid,
    AuthValidationError.invalidOtp => context.l10n.otpInvalid,
    AuthValidationError.firstNameRequired => context.l10n.firstNameRequired,
    AuthValidationError.invalidName => context.l10n.invalidName,
    AuthValidationError.birthDateRequired => context.l10n.birthDateRequired,
    AuthValidationError.invalidBirthDate => context.l10n.invalidBirthDate,
    AuthValidationError.futureBirthDate => context.l10n.futureBirthDate,
    AuthValidationError.underage => context.l10n.underage(minimumAge),
  };

  @override
  Widget build(BuildContext context) {
    final registrationSteps = ['phone', 'otp', 'name', 'dob'];
    final stepIndex = registrationSteps.indexOf(widget.step).clamp(0, 3);
    final phoneError = _phoneBlurred
        ? _validationMessage(validatePhone(_phone.text))
        : null;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.md,
                vertical: AppSpace.sm,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  if (_isRegistration)
                    _ProgressIndicator(
                      progress: (stepIndex + 1) / 4,
                      done: widget.step == 'dob',
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: AnimatedSwitcher(
                  duration: Motion.duration(context, Motion.standard),
                  switchInCurve: Motion.curve,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(.05, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(widget.step),
                    child: _buildStep(phoneError),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goBack() {
    switch (widget.step) {
      case 'phone':
        context.go('/onboarding');
      case 'otp':
        context.go('/auth/${widget.mode}/phone');
      case 'name':
        context.go('/auth/register/otp');
      case 'dob':
        context.go('/auth/register/name');
      default:
        context.go('/onboarding');
    }
  }

  Widget _buildStep(String? phoneError) => switch (widget.step) {
    'phone' => _phoneStep(phoneError),
    'otp' => _otpStep(),
    'name' => _nameStep(),
    'dob' => _birthDateStep(),
    _ => _phoneStep(phoneError),
  };

  Widget _phoneStep(String? phoneError) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _isRegistration
            ? context.l10n.phoneRegisterTitle
            : context.l10n.phoneLoginTitle,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: AppSpace.sm),
      Text(context.l10n.phoneDescription),
      const SizedBox(height: 36),
      TextField(
        controller: _phone,
        focusNode: _phoneFocus,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9 -]')),
        ],
        onChanged: _onPhoneChanged,
        decoration: InputDecoration(
          labelText: context.l10n.phoneLabel,
          prefixText: '+95  ',
          errorText: phoneError,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: AppSpace.sm),
        Text(_error!, style: const TextStyle(color: Colors.red)),
        if (!_isRegistration && _error == context.l10n.unknownNumber)
          TextButton(
            onPressed: () => context.go('/auth/register/phone'),
            child: Text(context.l10n.registerInstead),
          ),
      ],
      const SizedBox(height: AppSpace.lg),
      PrimaryButton(
        label: context.l10n.continueButton,
        enabled: validatePhone(_phone.text) == null,
        loading: _loading,
        onPressed: _continueFromPhone,
      ),
    ],
  );

  Widget _otpStep() {
    final draft = ref.watch(authDraftProvider);
    final minutes = _remainingSeconds ~/ 60;
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.otpTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpace.sm),
        Text(context.l10n.otpDescription(_phone.text)),
        const SizedBox(height: AppSpace.xl),
        AnimatedBuilder(
          animation: _shakeOffset,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeOffset.value, 0),
            child: child,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_otpDigits, _otpBox),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: AppSpace.md),
        Center(
          child: Text(
            _remainingSeconds > 0
                ? context.l10n.resendCountdown(minutes, seconds)
                : context.l10n.resendPrompt,
          ),
        ),
        Center(
          child: TextButton(
            onPressed: _remainingSeconds == 0 && !_loading ? _resendCode : null,
            child: Text(context.l10n.resendButton),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        PrimaryButton(
          label: context.l10n.verifyButton,
          enabled: draft.otp.length == _otpDigits && !draft.isOtpLocked,
          loading: _loading,
          onPressed: _verifyCode,
        ),
        const SizedBox(height: AppSpace.sm),
        Center(
          child: Text(
            context.l10n.demoCode,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _nameStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.nameTitle,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: AppSpace.lg),
      TextField(
        controller: _firstName,
        textCapitalization: TextCapitalization.words,
        maxLength: 50,
        onChanged: (value) {
          _saveDraft(ref.read(authDraftProvider).copyWith(firstName: value));
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: context.l10n.firstNameLabel,
          errorText: _nameSubmitted
              ? _validationMessage(validateFirstName(_firstName.text))
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      const SizedBox(height: AppSpace.md),
      TextField(
        controller: _lastName,
        textCapitalization: TextCapitalization.words,
        maxLength: 50,
        onChanged: (value) {
          _saveDraft(ref.read(authDraftProvider).copyWith(lastName: value));
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: context.l10n.lastNameLabel,
          errorText: _nameSubmitted
              ? _validationMessage(validateLastName(_lastName.text))
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      if (_error != null)
        Text(_error!, style: const TextStyle(color: Colors.red)),
      const SizedBox(height: AppSpace.lg),
      PrimaryButton(
        label: context.l10n.continueButton,
        loading: _loading,
        onPressed: _continueFromName,
      ),
    ],
  );

  Widget _birthDateStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.birthTitle,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: AppSpace.sm),
      Text(context.l10n.ageRequirement),
      const SizedBox(height: AppSpace.lg),
      OutlinedButton.icon(
        onPressed: _chooseBirthDate,
        icon: const Icon(Icons.calendar_month),
        label: Text(
          _birthDate == null
              ? context.l10n.selectBirthDate
              : '${_birthDate!.month}/${_birthDate!.day}/${_birthDate!.year}',
        ),
      ),
      if (_dateSubmitted)
        Padding(
          padding: const EdgeInsets.only(top: AppSpace.sm),
          child: Text(
            _validationMessage(validateBirthDate(_birthDate)) ?? '',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      if (_error != null)
        Text(_error!, style: const TextStyle(color: Colors.red)),
      const SizedBox(height: AppSpace.lg),
      PrimaryButton(
        label: context.l10n.continueButton,
        enabled: validateBirthDate(_birthDate) == null,
        loading: _loading,
        onPressed: _continueFromBirthDate,
      ),
    ],
  );

  Future<void> _chooseBirthDate() async {
    final now = ref.read(clockProvider)();
    final chosen = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (chosen == null || !mounted) return;
    _birthDate = chosen;
    _saveDraft(ref.read(authDraftProvider).copyWith(birthDate: chosen));
    setState(() {
      _dateSubmitted = true;
      _error = null;
    });
  }

  Widget _otpBox(int index) {
    final field = _otpFields[index];
    return SizedBox(
      width: 42,
      child: Focus(
        onKeyEvent: (_, event) {
          final isBackspace =
              event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace;
          if (isBackspace && field.text.isEmpty && index > 0) {
            _otpFocus[index - 1].requestFocus();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: field,
          focusNode: _otpFocus[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: _otpDigits,
          autofillHints: index == 0 ? const [AutofillHints.oneTimeCode] : null,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _onOtpFieldChanged(index, value),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.canvas,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _onOtpFieldChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      final pasted = digits.length > _otpDigits
          ? digits.substring(0, _otpDigits)
          : digits;
      for (var digitIndex = 0; digitIndex < _otpDigits; digitIndex++) {
        _otpFields[digitIndex].text = digitIndex < pasted.length
            ? pasted[digitIndex]
            : '';
      }
      _otpFocus[pasted.length == _otpDigits ? _otpDigits - 1 : pasted.length]
          .requestFocus();
    } else if (value.isNotEmpty && index < _otpDigits - 1) {
      _otpFocus[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocus[index - 1].requestFocus();
    }
    _onOtpChanged();
  }
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
