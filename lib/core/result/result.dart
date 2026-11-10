sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(this.code, super.message);

  final AuthFailureCode code;
}

enum AuthFailureCode {
  incorrectCode,
  unknownNumber,
  unverifiedNumber,
  registrationIncomplete,
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
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
