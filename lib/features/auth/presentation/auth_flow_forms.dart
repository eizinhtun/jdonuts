part of 'auth_flow.dart';

mixin _AuthFlowForms on _AuthFlowHost, _AuthFlowActions, _AuthFlowInputs {
  Widget _buildStep(String? phoneError) => switch (widget.step) {
    'phone' => _phoneStep(phoneError),
    'otp' => _otpStep(),
    'name' => _nameStep(),
    'dob' => _birthDateStep(),
    _ => _phoneStep(phoneError),
  };

  Widget _stepHeadline(String text) => SizedBox(
    width: 260,
    child: Text(text, style: Theme.of(context).textTheme.headlineMedium),
  );

  Widget _legalFooter(BuildContext context) => Padding(
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
      const SizedBox(height: AppSpace.sm),
      Text(context.l10n.phoneDescription),
      const SizedBox(height: 36),
      TextField(
        controller: _phone,
        focusNode: _phoneFocus,
        enabled: !_loading,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9 -]')),
        ],
        onChanged: _onPhoneChanged,
        decoration: InputDecoration(
          labelText: context.l10n.phoneLabel,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Center(
              widthFactor: 1,
              child: Text('+95', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 56),
          errorText: phoneError,
          filled: true,
          fillColor: AppColors.white,
          border: _inputBorder(),
          enabledBorder: _inputBorder(),
          focusedBorder: _inputBorder(color: AppColors.pink),
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
        _stepHeadline(context.l10n.otpTitle),
        const SizedBox(height: AppSpace.sm),
        Text(context.l10n.otpDescription(_phoneValue)),
        const SizedBox(height: AppSpace.xl),
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
              (index) =>
                  _otpBox(index, disabled: draft.isOtpLocked || _loading),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: AppColors.error)),
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
        Center(
          child: Text(
            context.l10n.demoCode,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
        const Spacer(),
        PrimaryButton(
          label: context.l10n.verifyButton,
          enabled: draft.otp.length == _otpDigits && !draft.isOtpLocked,
          loading: _loading,
          onPressed: _verifyCode,
        ),
      ],
    );
  }

  Widget _nameStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _stepHeadline(context.l10n.nameTitle),
      const SizedBox(height: AppSpace.lg),
      TextField(
        controller: _firstName,
        enabled: !_loading,
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
          filled: true,
          fillColor: AppColors.white,
          border: _inputBorder(),
          enabledBorder: _inputBorder(),
          focusedBorder: _inputBorder(color: AppColors.pink),
        ),
      ),
      const SizedBox(height: AppSpace.md),
      TextField(
        controller: _lastName,
        enabled: !_loading,
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
          filled: true,
          fillColor: AppColors.white,
          border: _inputBorder(),
          enabledBorder: _inputBorder(),
          focusedBorder: _inputBorder(color: AppColors.pink),
        ),
      ),
      if (_error != null)
        Text(_error!, style: const TextStyle(color: AppColors.error)),
      const Spacer(),
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
      _stepHeadline(context.l10n.birthTitle),
      const SizedBox(height: AppSpace.sm),
      Text(context.l10n.ageRequirement),
      const SizedBox(height: AppSpace.lg),
      OutlinedButton.icon(
        onPressed: _loading ? null : _chooseBirthDate,
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
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      if (_error != null)
        Text(_error!, style: const TextStyle(color: AppColors.error)),
      const Spacer(),
      PrimaryButton(
        label: context.l10n.continueButton,
        enabled: validateBirthDate(_birthDate) == null,
        loading: _loading,
        onPressed: _continueFromBirthDate,
      ),
    ],
  );
}
