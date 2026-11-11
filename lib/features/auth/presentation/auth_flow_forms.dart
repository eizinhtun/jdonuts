part of 'auth_flow.dart';

mixin _AuthFlowForms on _AuthFlowHost, _AuthFlowActions, _AuthFlowInputs {
  Widget _buildStep(String? phoneError) => switch (widget.step) {
    'phone' => _phoneStep(phoneError),
    'otp' => _otpStep(),
    'name' => _nameStepFields(),
    'dob' => _birthDateStepFields(),
    _ => _phoneStep(phoneError),
  };

  Widget _stepHeadline(String text) {
    final width = switch (widget.step) {
      'phone' => 320.0,
      'name' => 250.0,
      'dob' => 280.0,
      _ => double.infinity,
    };
    final referenceStyle = _useReferenceAuthLayout;
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: referenceStyle
            ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: Theme.of(context).platform == TargetPlatform.iOS
                    ? 'SF Pro Rounded'
                    : null,
                fontSize: widget.step == 'otp' ? 30 : 34,
                fontWeight: FontWeight.w700,
                height: 1.12,
                letterSpacing: -.25,
              )
            : Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _legalFooter(BuildContext context) {
    if (_useReferenceAuthLayout) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
        child: OnboardingLegalNotice(
          onTerms: () =>
              _showLegalPlaceholder(context, context.l10n.termsLabel),
          onPrivacy: () =>
              _showLegalPlaceholder(context, context.l10n.privacyLabel),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.l10n.legalAcknowledgement,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
          _legalLink(context, context.l10n.termsLabel),
          Text(
            context.l10n.andLabel,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
          _legalLink(context, context.l10n.privacyLabel),
        ],
      ),
    );
  }

  void _showLegalPlaceholder(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.socialPlaceholder(label))),
    );
  }

  Widget _legalLink(BuildContext context, String label) => TextButton(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),
    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.socialPlaceholder(label))),
    ),
    child: Text(label, style: const TextStyle(fontSize: 10)),
  );

  Widget _phoneStep(String? phoneError) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepHeadline(
        _isRegistration
            ? context.l10n.phoneRegisterTitle
            : context.l10n.phoneLoginTitle,
      ),
      if (_useReferenceAuthLayout)
        const SizedBox(height: 40)
      else ...[
        const SizedBox(height: AppSpace.sm),
        Text(context.l10n.phoneDescription),
        const SizedBox(height: 36),
      ],
      TextField(
        controller: _phone,
        focusNode: _phoneFocus,
        enabled: !_loading,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9 -]')),
        ],
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onChanged: _onPhoneChanged,
        style: _useReferenceAuthLayout
            ? const TextStyle(fontSize: 18, color: AppColors.ink)
            : null,
        decoration: InputDecoration(
          hintText: context.l10n.phoneHint,
          prefixIcon: Padding(
            padding: EdgeInsets.only(
              left: _useReferenceAuthLayout ? 22 : 14,
              right: 10,
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                '+95',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: _useReferenceAuthLayout ? 18 : null,
                  color: _useReferenceAuthLayout ? AppColors.fieldHint : null,
                ),
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            minWidth: _useReferenceAuthLayout ? 82 : 56,
          ),
          contentPadding: _useReferenceAuthLayout
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 26)
              : null,
          errorText: phoneError,
          filled: true,
          fillColor: AppColors.white,
          border: _inputBorder(),
          enabledBorder: _inputBorder(),
          focusedBorder: _inputBorder(color: AppColors.pink),
          errorBorder: _inputBorder(color: AppColors.error),
          focusedErrorBorder: _inputBorder(color: AppColors.error),
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: AppSpace.sm),
        Text(_error!, style: const TextStyle(color: AppColors.error)),
        if (!_isRegistration && _error == context.l10n.unknownNumber)
          TextButton(
            onPressed: () => context.go('/auth/register/phone'),
            child: Text(context.l10n.registerInstead),
          ),
      ],
      const Spacer(),
      DefaultTextStyle.merge(
        style: _useReferenceAuthLayout
            ? const TextStyle(fontSize: 16, letterSpacing: .5)
            : const TextStyle(),
        child: PrimaryButton(
          label: context.l10n.continueButton,
          height: _useReferenceAuthLayout ? 56 : 52,
          enabled: validatePhone(_phone.text) == null,
          loading: _loading,
          onPressed: _continueFromPhone,
        ),
      ),
    ],
  );

  Widget _otpStep() {
    final draft = ref.watch(authDraftProvider);
    final minutes = _remainingSeconds ~/ 60;
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final otpRowWidth =
        MediaQuery.sizeOf(context).width - (_useReferenceAuthLayout ? 72 : 48);
    final otpGap = otpRowWidth < 300 ? 6.0 : 8.0;
    final otpBoxWidth = _useReferenceAuthLayout
        ? ((otpRowWidth - otpGap * (_otpDigits - 1)) / _otpDigits).clamp(
            36.0,
            48.0,
          )
        : 42.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeadline(context.l10n.otpTitle),
        SizedBox(height: _useReferenceAuthLayout ? 20 : AppSpace.sm),
        Text(
          _useReferenceAuthLayout
              ? context.l10n.registerOtpDescription(_phoneValue)
              : context.l10n.otpDescription(_phoneValue),
        ),
        SizedBox(height: _useReferenceAuthLayout ? 37 : AppSpace.xl),
        AnimatedBuilder(
          animation: _shakeOffset,
          builder: (context, child) => Transform.translate(
            offset: Offset(_shakeOffset.value, 0),
            child: child,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              _otpDigits,
              (index) => _otpBox(
                index,
                width: otpBoxWidth,
                disabled: draft.isOtpLocked || _loading,
              ),
            ),
          ),
        ),
        SizedBox(height: _useReferenceAuthLayout ? 21 : AppSpace.sm),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: AppColors.error)),
        if (_useReferenceAuthLayout) ...[
          Text(
            context.l10n.registerResendPrompt,
            style: const TextStyle(fontSize: 16, color: AppColors.ink),
          ),
          if (_remainingSeconds > 0)
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 16, color: AppColors.ink),
                children: [
                  TextSpan(text: context.l10n.resendCountdownPrefix),
                  TextSpan(
                    text: '$minutes:$seconds',
                    style: const TextStyle(color: AppColors.pink),
                  ),
                  TextSpan(text: context.l10n.resendCountdownSuffix),
                ],
              ),
            )
          else
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft,
              ),
              onPressed: !_loading ? _resendCode : null,
              child: Text(context.l10n.resendButton),
            ),
        ] else ...[
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
              onPressed: _remainingSeconds == 0 && !_loading
                  ? _resendCode
                  : null,
              child: Text(context.l10n.resendButton),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          Center(
            child: Text(
              context.l10n.demoCode,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
        const Spacer(),
        if (!_useReferenceAuthLayout || draft.otp.isNotEmpty || _loading)
          DefaultTextStyle.merge(
            style: _useReferenceAuthLayout
                ? const TextStyle(fontSize: 16, letterSpacing: .5)
                : const TextStyle(),
            child: PrimaryButton(
              label: context.l10n.verifyButton,
              height: _useReferenceAuthLayout ? 56 : 52,
              enabled: draft.otp.length == _otpDigits && !draft.isOtpLocked,
              loading: _loading,
              onPressed: _verifyCode,
            ),
          ),
      ],
    );
  }

  Widget _stickyFormScreen({required Widget fields, required Widget action}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(top: _useReferenceAuthLayout ? 30 : 20),
              child: fields,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: _useReferenceAuthLayout ? 57 : 14),
            child: action,
          ),
        ],
      );

  Widget _nameStepScreen() => _stickyFormScreen(
    fields: _nameStepFields(),
    action: _nameContinueButton(),
  );

  Widget _birthDateStepScreen() => _stickyFormScreen(
    fields: _birthDateStepFields(),
    action: _birthDateContinueButton(),
  );

  Widget _nameStepFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeadline(context.l10n.nameTitle),
        SizedBox(height: _useReferenceAuthLayout ? 40 : AppSpace.lg),
        TextField(
          controller: _firstName,
          enabled: !_loading,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          textCapitalization: TextCapitalization.words,
          maxLength: 50,
          onChanged: (value) {
            _saveDraft(ref.read(authDraftProvider).copyWith(firstName: value));
            setState(() {});
          },
          style: _useReferenceAuthLayout
              ? const TextStyle(fontSize: 18, color: AppColors.ink)
              : null,
          decoration: InputDecoration(
            hintText: context.l10n.firstNameLabel,
            counterText: '',
            errorText: _nameSubmitted
                ? _validationMessage(validateFirstName(_firstName.text))
                : null,
            filled: true,
            fillColor: AppColors.white,
            hintStyle: _useReferenceAuthLayout
                ? const TextStyle(color: AppColors.fieldHint, fontSize: 18)
                : null,
            contentPadding: _useReferenceAuthLayout
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                : null,
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(color: AppColors.pink),
            errorBorder: _inputBorder(color: AppColors.error),
            focusedErrorBorder: _inputBorder(color: AppColors.error),
          ),
        ),
        SizedBox(height: _useReferenceAuthLayout ? 20 : AppSpace.md),
        TextField(
          controller: _lastName,
          enabled: !_loading,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          textCapitalization: TextCapitalization.words,
          maxLength: 50,
          onChanged: (value) {
            _saveDraft(ref.read(authDraftProvider).copyWith(lastName: value));
            setState(() {});
          },
          style: _useReferenceAuthLayout
              ? const TextStyle(fontSize: 18, color: AppColors.ink)
              : null,
          decoration: InputDecoration(
            hintText: context.l10n.lastNameLabel,
            counterText: '',
            errorText: _nameSubmitted
                ? _validationMessage(validateLastName(_lastName.text))
                : null,
            filled: true,
            fillColor: AppColors.white,
            hintStyle: _useReferenceAuthLayout
                ? const TextStyle(color: AppColors.fieldHint, fontSize: 18)
                : null,
            contentPadding: _useReferenceAuthLayout
                ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
                : null,
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(color: AppColors.pink),
            errorBorder: _inputBorder(color: AppColors.error),
            focusedErrorBorder: _inputBorder(color: AppColors.error),
          ),
        ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: AppColors.error)),
      ],
    );
  }

  Widget _nameContinueButton() => DefaultTextStyle.merge(
    style: _useReferenceAuthLayout
        ? const TextStyle(fontSize: 16, letterSpacing: .5)
        : const TextStyle(),
    child: PrimaryButton(
      label: context.l10n.continueButton,
      height: _useReferenceAuthLayout ? 56 : 52,
      loading: _loading,
      onPressed: _continueFromName,
    ),
  );

  Widget _birthDateStepFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepHeadline(context.l10n.birthTitle),
        if (!_useReferenceAuthLayout) ...[
          const SizedBox(height: AppSpace.sm),
          Text(context.l10n.ageRequirement),
        ],
        SizedBox(height: _useReferenceAuthLayout ? 40 : AppSpace.lg),
        _birthDateField(
          controller: _birthMonth,
          hint: context.l10n.birthMonthHint,
          onChanged: (value) => _onBirthPartChanged('month', value),
          capitalization: TextCapitalization.words,
        ),
        SizedBox(height: _useReferenceAuthLayout ? 20 : AppSpace.sm),
        _birthDateField(
          controller: _birthDay,
          hint: context.l10n.birthDayHint,
          onChanged: (value) => _onBirthPartChanged('day', value),
          keyboardType: TextInputType.number,
          formatter: FilteringTextInputFormatter.digitsOnly,
          maxLength: 2,
        ),
        SizedBox(height: _useReferenceAuthLayout ? 20 : AppSpace.sm),
        _birthDateField(
          controller: _birthYear,
          hint: context.l10n.birthYearHint,
          onChanged: (value) => _onBirthPartChanged('year', value),
          keyboardType: TextInputType.number,
          formatter: FilteringTextInputFormatter.digitsOnly,
          maxLength: 4,
        ),
        if (_dateSubmitted)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.sm),
            child: Text(
              _validationMessage(
                    validateBirthInputs(
                      _birthMonth.text,
                      _birthDay.text,
                      _birthYear.text,
                      today: ref.read(clockProvider)(),
                    ),
                  ) ??
                  '',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: AppColors.error)),
      ],
    );
  }

  Widget _birthDateContinueButton() => DefaultTextStyle.merge(
    style: _useReferenceAuthLayout
        ? const TextStyle(fontSize: 16, letterSpacing: .5)
        : const TextStyle(),
    child: PrimaryButton(
      label: context.l10n.continueButton,
      height: _useReferenceAuthLayout ? 56 : 52,
      enabled: !_loading,
      loading: _loading,
      onPressed: _continueFromBirthDate,
    ),
  );

  Widget _birthDateField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    TextCapitalization capitalization = TextCapitalization.none,
    TextInputType? keyboardType,
    TextInputFormatter? formatter,
    int? maxLength,
  }) => TextField(
    controller: controller,
    enabled: !_loading,
    textCapitalization: capitalization,
    keyboardType: keyboardType,
    maxLength: maxLength,
    inputFormatters: formatter == null ? null : [formatter],
    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    onChanged: onChanged,
    style: _useReferenceAuthLayout
        ? const TextStyle(fontSize: 18, color: AppColors.ink)
        : null,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: _useReferenceAuthLayout
          ? const TextStyle(color: AppColors.fieldHint, fontSize: 18)
          : null,
      counterText: '',
      contentPadding: _useReferenceAuthLayout
          ? const EdgeInsets.symmetric(horizontal: 20, vertical: 24)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: AppColors.white,
      border: _inputBorder(),
      enabledBorder: _inputBorder(),
      focusedBorder: _inputBorder(color: AppColors.pink),
      errorBorder: _inputBorder(color: AppColors.error),
      focusedErrorBorder: _inputBorder(color: AppColors.error),
    ),
  );
}
