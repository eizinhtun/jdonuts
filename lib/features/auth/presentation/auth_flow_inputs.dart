part of 'auth_flow.dart';

mixin _AuthFlowInputs on _AuthFlowHost, _AuthFlowActions {
  void _onBirthPartChanged(String field, String value) {
    final draft = ref.read(authDraftProvider);
    final month = field == 'month' ? value : _birthMonth.text;
    final day = field == 'day' ? value : _birthDay.text;
    final year = field == 'year' ? value : _birthYear.text;
    _birthDate = parseBirthDate(month, day, year);
    _saveDraft(
      draft.copyWith(
        birthMonth: month,
        birthDay: day,
        birthYear: year,
        birthDate: _birthDate,
        clearBirthDate: _birthDate == null,
      ),
    );
    setState(() {
      _error = null;
    });
  }

  Widget _otpBox(int index, {required bool disabled}) {
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
          enabled: !disabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: _otpDigits,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          autofillHints: index == 0 ? const [AutofillHints.oneTimeCode] : null,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _onOtpFieldChanged(index, value),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: AppColors.white,
            border: _inputBorder(),
            enabledBorder: _inputBorder(),
            focusedBorder: _inputBorder(color: AppColors.pink),
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
