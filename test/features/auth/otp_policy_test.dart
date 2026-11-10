import 'package:flutter_test/flutter_test.dart';
import 'package:jdonuts/features/auth/domain/otp_policy.dart';
import 'package:jdonuts/features/auth/presentation/auth_draft.dart';

void main() {
  test(
    'resend countdown starts at five minutes and rounds up remaining time',
    () {
      final sentAt = DateTime(2026, 11, 10, 12);
      final deadline = otpResendDeadline(sentAt);
      expect(secondsUntilOtpResend(deadline, sentAt), 300);
      expect(
        secondsUntilOtpResend(
          deadline,
          sentAt.add(
            const Duration(minutes: 4, seconds: 59, milliseconds: 100),
          ),
        ),
        1,
      );
      expect(secondsUntilOtpResend(deadline, deadline), 0);
      expect(secondsUntilOtpResend(null, sentAt), 0);
    },
  );

  test('third wrong entry locks until an eligible resend', () {
    var draft = const AuthDraft();
    draft = draft.copyWith(otpFailures: 1);
    expect(draft.isOtpLocked, isFalse);
    draft = draft.copyWith(otpFailures: 2);
    expect(draft.isOtpLocked, isFalse);
    draft = draft.copyWith(otpFailures: 3);
    expect(draft.isOtpLocked, isTrue);
    expect(draft.copyWith(otpFailures: 0).isOtpLocked, isFalse);
  });

  test('draft navigation updates preserve the resend deadline', () {
    final deadline = DateTime(2026, 11, 10, 12, 5);
    final draft = const AuthDraft(phone: '9254135592')
        .copyWith(otpFailures: 2, firstName: 'May', resendDeadline: deadline);
    final changed = draft.copyWith(lastName: 'Aung');
    expect(changed.phone, '9254135592');
    expect(changed.firstName, 'May');
    expect(changed.lastName, 'Aung');
    expect(changed.otpFailures, 2);
    expect(changed.resendDeadline, deadline);
  });
}
