import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jdonuts/features/auth/presentation/widgets/primary_button.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/tokens.dart';
import '../../../main.dart';
import '../domain/auth_repository.dart';
import '../domain/validators.dart';

enum AuthMode { register, login }

class AuthFlow extends ConsumerStatefulWidget {
  const AuthFlow({super.key, required this.mode, required this.step});
  final String mode, step;
  @override
  ConsumerState<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends ConsumerState<AuthFlow>
    with SingleTickerProviderStateMixin {
  final phone = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());
  final otpFocus = List.generate(6, (_) => FocusNode());
  final phoneFocus = FocusNode();
  Timer? timer;
  int remaining = 300, failures = 0;
  DateTime? birthDate;
  bool loading = false,
      phoneBlurred = false,
      shaking = false,
      attempted = false;
  String? error;
  AuthMode get mode =>
      widget.mode == 'login' ? AuthMode.login : AuthMode.register;
  String get step => widget.step;
  String get normalizedPhone => '+95${normalizePhone(phone.text)}';
  String get otp => otpControllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    phoneFocus.addListener(() {
      if (!phoneFocus.hasFocus) setState(() => phoneBlurred = true);
    });
    if (step == 'otp') _startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    phone.dispose();
    firstName.dispose();
    lastName.dispose();
    phoneFocus.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context)) return;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remaining > 0 && mounted) setState(() => remaining--);
    });
  }

  Future<void> _sendPhone() async {
    if (loading || validatePhone(phone.text) != null) return;
    setState(() {
      loading = true;
      error = null;
    });
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    final canonical = normalizePhone(phone.text);
    if (mode == AuthMode.login &&
        !await ref.read(authRepositoryProvider).isRegistered('95$canonical')) {
      setState(() {
        loading = false;
        error = 'This number is new. Register to continue.';
      });
      return;
    }
    setState(() => loading = false);
    context.go('/auth/${widget.mode}/otp', extra: canonical);
  }

  Future<void> _verify() async {
    if (loading || failures >= 3 || validateOtp(otp) != null) return;
    setState(() {
      loading = true;
      error = null;
    });
    final user = AuthUser(
      phone: '95${normalizePhone(phone.text)}',
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      birthDate: birthDate,
    );
    final result = mode == AuthMode.login
        ? await ref.read(authRepositoryProvider).login(user.phone, otp)
        : await ref.read(authRepositoryProvider).register(user, otp);
    if (!mounted) return;
    setState(() => loading = false);
    result.fold(
      (_) {
        ref.read(authStateProvider.notifier).state = true;
        context.go(mode == AuthMode.register ? '/welcome' : '/home');
      },
      (failure) {
        if (failure.message.contains('new')) {
          setState(() => error = failure.message);
          return;
        }
        failures++;
        setState(() {
          error = failures >= 3
              ? 'Too many attempts. Resend the code when the timer ends.'
              : 'That code is incorrect.';
          shaking = true;
        });
        Future<void>.delayed(Motion.duration(context, Motion.standard), () {
          if (mounted) setState(() => shaking = false);
        });
        for (final c in otpControllers) {
          c.clear();
        }
        otpFocus.first.requestFocus();
      },
    );
  }

  Future<void> _continueProfile() async {
    if (loading) return;
    final nameError =
        validateFirstName(firstName.text) ?? validateLastName(lastName.text);
    if (nameError != null) {
      setState(() {
        attempted = true;
        error = nameError;
      });
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => loading = false);
    context.go(
      '/auth/register/dob',
      extra: {
        'phone': phone.text,
        'first': firstName.text,
        'last': lastName.text,
      },
    );
  }

  Future<void> _continueDob() async {
    final message = validateBirthDate(birthDate);
    if (message != null) {
      setState(() {
        attempted = true;
        error = message;
      });
      return;
    }
    if (loading) return;
    setState(() => loading = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => loading = false);
    final user = AuthUser(
      phone: '95${normalizePhone(phone.text)}',
      firstName: firstName.text.trim(),
      lastName: lastName.text.trim(),
      birthDate: birthDate,
    );
    await ref.read(authRepositoryProvider).remember(user);
    ref.read(authStateProvider.notifier).state = true;
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final registrationSteps = ['phone', 'otp', 'name', 'dob'];
    final stepIndex = registrationSteps.indexOf(step).clamp(0, 3);
    final phoneError = phoneBlurred ? validatePhone(phone.text) : null;
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
                    onPressed: () {
                      if (step == 'phone')
                        context.go('/onboarding');
                      else if (step == 'otp')
                        context.go('/auth/${widget.mode}/phone');
                      else if (step == 'name')
                        context.go('/auth/${widget.mode}/otp');
                      else
                        context.go('/auth/${widget.mode}/name');
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const Spacer(),
                  if (mode == AuthMode.register)
                    _ProgressIndicator(
                      progress: (stepIndex + 1) / 4,
                      done: step == 'dob',
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: _content(phoneError),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(String? phoneError) {
    if (step == 'phone')
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mode == AuthMode.login ? 'Log in' : 'What’s your phone number?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          const Text('We’ll send you a code to verify your number.'),
          const SizedBox(height: 36),
          TextField(
            controller: phone,
            focusNode: phoneFocus,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9 -]')),
            ],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Phone number',
              prefixText: '+95  ',
              errorText: phoneError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'CONTINUE',
            enabled: validatePhone(phone.text) == null,
            loading: loading,
            onPressed: _sendPhone,
          ),
        ],
      );
    if (step == 'otp')
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify number',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text('Enter the 6-digit code sent to +95 ${phone.text}'),
          const SizedBox(height: 32),
          AnimatedContainer(
            duration: Motion.duration(context, Motion.quick),
            transform: Matrix4.translationValues(shaking ? 9 : 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, _otpBox),
            ),
          ),
          const SizedBox(height: 12),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          Center(
            child: Text(
              remaining > 0
                  ? 'Resend code in ${remaining ~/ 60}:${(remaining % 60).toString().padLeft(2, '0')}'
                  : 'Didn’t receive a code?',
            ),
          ),
          Center(
            child: TextButton(
              onPressed: remaining == 0
                  ? () {
                      setState(() {
                        remaining = 300;
                        failures = 0;
                        error = null;
                      });
                      _startTimer();
                    }
                  : null,
              child: const Text('Resend code'),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'VERIFY',
            enabled: otp.length == 6 && failures < 3,
            loading: loading,
            onPressed: _verify,
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Demo verification code: 123456',
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
      );
    if (step == 'name')
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What’s your name?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 30),
          TextField(
            controller: firstName,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'First name',
              errorText: attempted ? validateFirstName(firstName.text) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: lastName,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Last name (optional)',
              errorText: attempted ? validateLastName(lastName.text) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 30),
          PrimaryButton(
            label: 'CONTINUE',
            loading: loading,
            enabled:
                validateFirstName(firstName.text) == null &&
                validateLastName(lastName.text) == null,
            onPressed: _continueProfile,
          ),
        ],
      );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When’s your birthday?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        const Text('You must be 13 or older to join.'),
        const SizedBox(height: 36),
        OutlinedButton.icon(
          onPressed: () async {
            final now = DateTime.now();
            final chosen = await showDatePicker(
              context: context,
              initialDate: DateTime(now.year - 18),
              firstDate: DateTime(1900),
              lastDate: now,
            );
            if (chosen != null) setState(() => birthDate = chosen);
          },
          icon: const Icon(Icons.calendar_month),
          label: Text(
            birthDate == null
                ? 'Select date of birth'
                : '${birthDate!.month}/${birthDate!.day}/${birthDate!.year}',
          ),
        ),
        if (attempted && error != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(error!, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 30),
        PrimaryButton(
          label: 'CONTINUE',
          loading: loading,
          enabled: validateBirthDate(birthDate) == null,
          onPressed: _continueDob,
        ),
      ],
    );
  }

  Widget _otpBox(int index) => SizedBox(
    width: 45,
    child: TextField(
      controller: otpControllers[index],
      focusNode: otpFocus[index],
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      autofillHints: index == 0 ? const [AutofillHints.oneTimeCode] : null,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (value) {
        if (value.length > 1) {
          final code = value.padRight(6).substring(0, 6);
          for (var i = 0; i < 6; i++) {
            otpControllers[i].text = code[i] == ' ' ? '' : code[i];
          }
          otpFocus.last.unfocus();
          setState(() {});
          return;
        }
        if (value.isNotEmpty && index < 5)
          otpFocus[index + 1].requestFocus();
        else if (value.isEmpty && index > 0)
          otpFocus[index - 1].requestFocus();
        setState(() {});
      },
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: AppColors.canvas,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.progress, required this.done});
  final double progress;
  final bool done;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 44,
    height: 44,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: progress,
          strokeWidth: 3,
          backgroundColor: AppColors.canvas,
          color: AppColors.pink,
        ),
        Icon(
          done ? Icons.check : Icons.circle,
          size: done ? 18 : 6,
          color: AppColors.pink,
        ),
      ],
    ),
  );
}
