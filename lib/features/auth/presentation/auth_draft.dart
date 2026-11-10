import '../domain/otp_policy.dart';

class AuthDraft {
  const AuthDraft({
    this.phone = '',
    this.firstName = '',
    this.lastName = '',
    this.otp = '',
    this.otpFailures = 0,
    this.otpVerified = false,
    this.birthDate,
    this.birthMonth = '',
    this.birthDay = '',
    this.birthYear = '',
    this.resendDeadline,
  });

  final String phone;
  final String firstName;
  final String lastName;
  final String otp;
  final int otpFailures;
  final bool otpVerified;
  final DateTime? birthDate;
  final String birthMonth;
  final String birthDay;
  final String birthYear;
  final DateTime? resendDeadline;

  bool get isOtpLocked => otpFailures >= otpAttemptLimit;

  AuthDraft copyWith({
    String? phone,
    String? firstName,
    String? lastName,
    String? otp,
    int? otpFailures,
    bool? otpVerified,
    DateTime? birthDate,
    String? birthMonth,
    String? birthDay,
    String? birthYear,
    DateTime? resendDeadline,
    bool clearBirthDate = false,
    bool clearResendDeadline = false,
  }) => AuthDraft(
    phone: phone ?? this.phone,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    otp: otp ?? this.otp,
    otpFailures: otpFailures ?? this.otpFailures,
    otpVerified: otpVerified ?? this.otpVerified,
    birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
    birthMonth: birthMonth ?? this.birthMonth,
    birthDay: birthDay ?? this.birthDay,
    birthYear: birthYear ?? this.birthYear,
    resendDeadline: clearResendDeadline
        ? null
        : resendDeadline ?? this.resendDeadline,
  );
}
