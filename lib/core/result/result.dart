sealed class Failure {
  const Failure(
    this.message, {
    this.cause,
    this.stackTrace,
    this.secondaryCause,
    this.secondaryStackTrace,
  });

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;
  final Object? secondaryCause;
  final StackTrace? secondaryStackTrace;
}

final class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    super.cause,
    super.stackTrace,
    super.secondaryCause,
    super.secondaryStackTrace,
  });
}

final class AuthFailure extends Failure {
  const AuthFailure(
    this.code,
    super.message, {
    super.cause,
    super.stackTrace,
    super.secondaryCause,
    super.secondaryStackTrace,
  });

  final AuthFailureCode code;
}

enum AuthFailureCode {
  incorrectCode,
  unknownNumber,
  unverifiedNumber,
  registrationIncomplete,
  serviceUnavailable,
}

final class StorageFailure extends Failure {
  const StorageFailure(
    super.message, {
    super.cause,
    super.stackTrace,
    super.secondaryCause,
    super.secondaryStackTrace,
  });
}

final class NetworkFailure extends Failure {
  const NetworkFailure(
    super.message, {
    super.cause,
    super.stackTrace,
    super.secondaryCause,
    super.secondaryStackTrace,
  });
}

sealed class Result<T> {
  const Result();
  R fold<R>(R Function(T value) success, R Function(Failure failure) error);
}

class ResultException implements Exception {
  const ResultException(this.failure);

  final Failure failure;

  @override
  String toString() => failure.message;
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
  @override
  R fold<R>(R Function(T value) success, R Function(Failure failure) error) =>
      success(value);
}

final class Error<T> extends Result<T> {
  const Error(this.failure);
  final Failure failure;
  @override
  R fold<R>(R Function(T value) success, R Function(Failure failure) error) =>
      error(failure);
}
