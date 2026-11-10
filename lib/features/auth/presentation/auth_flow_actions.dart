part of 'auth_flow.dart';

mixin _AuthFlowActions on _AuthFlowHost {
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
    final validation = validateBirthInputs(
      _birthMonth.text,
      _birthDay.text,
      _birthYear.text,
      today: ref.read(clockProvider)(),
    );
    if (validation != null) {
      setState(() => _dateSubmitted = true);
      return;
    }
    if (_loading) return;
    final birthDate = parseBirthDate(
      _birthMonth.text,
      _birthDay.text,
      _birthYear.text,
    );
    if (birthDate == null) return;
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
      birthDate: birthDate,
    );
    final result = await ref.read(authRepositoryProvider).register(user);
    if (!mounted) return;
    result.fold<void>(
      (_) {
        _saveDraft(
          ref
              .read(authDraftProvider)
              .copyWith(birthDate: birthDate, otpVerified: false),
        );
        ref.read(authStateProvider.notifier).state = true;
        context.go('/welcome');
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
}
