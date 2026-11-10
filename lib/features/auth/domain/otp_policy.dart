const otpAttemptLimit = 3;
const otpResendWindow = Duration(minutes: 5);

DateTime otpResendDeadline(DateTime sentAt) => sentAt.add(otpResendWindow);

int secondsUntilOtpResend(DateTime? deadline, DateTime now) {
  if (deadline == null) return 0;
  final milliseconds = deadline.difference(now).inMilliseconds;
  if (milliseconds <= 0) return 0;
  return (milliseconds + 999) ~/ 1000;
}
