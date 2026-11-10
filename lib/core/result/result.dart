sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

sealed class Result<T> {
  const Result();
  R fold<R>(R Function(T value) success, R Function(Failure failure) error);
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
