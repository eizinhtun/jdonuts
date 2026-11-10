part of 'auth_flow.dart';

mixin _AuthFlowInputs on _AuthFlowHost, _AuthFlowActions {
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
